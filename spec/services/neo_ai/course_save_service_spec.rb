# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeoAi::CourseSaveService do
  let(:neo_ai) { instance_double(NeoAi::Client) }
  let(:service) { described_class.new(neo_ai) }
  let(:learning_partner) { create(:learning_partner) }
  let(:neo_ai_data) do
    {
      'title' => 'Test Course Title',
      'description' => 'An AI generated course about a very interesting topic for learners',
      'level' => 'Beginner',
      'modules' => [
        {
          'id' => 'm1',
          'title' => 'Module One',
          'lessons' => [
            {
              'id' => 'l1',
              'title' => 'Lesson One',
              'description' => 'Introduction to the topic',
              'estimated_duration' => 90,
              'video_url' => 'https://neo.ai/video.mp4'
            }
          ]
        }
      ]
    }
  end

  before do
    allow(neo_ai).to receive(:find_course).with('neo-c1').and_return(neo_ai_data)
    allow(NeoAi::DownloadLessonVideoJob).to receive(:perform_async)
  end

  describe '#call — initial save' do
    it 'creates a course with correct attributes' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.title).to eq('Test Course Title')
      expect(course.neo_ai_course_id).to eq('neo-c1')
      expect(course.visibility).to eq('private')
    end

    it 'creates modules with neo_ai_module_id and correct ordering' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.first
      expect(mod.neo_ai_module_id).to eq('m1')
      expect(course.course_modules_in_order).to eq([mod.id])
    end

    it 'creates lessons with neo_ai_lesson_id, duration, and video source' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      lesson = course.course_modules.first.lessons.first
      expect(lesson.neo_ai_lesson_id).to eq('l1')
      expect(lesson.title).to eq('Lesson One')
      expect(lesson.duration).to eq(90)
      expect(lesson.video_streaming_source).to eq('https://neo.ai/video.mp4')
    end

    it 'sets lessons_in_order on the module' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.first
      expect(mod.lessons_in_order).to eq([mod.lessons.first.id])
    end

    it 'enqueues a video download job for each lesson with a video URL' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      lesson = course.course_modules.first.lessons.first
      expect(NeoAi::DownloadLessonVideoJob).to have_received(:perform_async).with(lesson.id)
    end

    it 'attaches the level tag from the API response' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.tags.select(&:level?).map(&:name)).to contain_exactly('Beginner')
    end

    it 'skips level tag when level is absent' do
      neo_ai_data.delete('level')
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.tags.select(&:level?)).to be_empty
    end
  end

  describe '#call — re-save (course already exists)' do
    let!(:existing_course) do
      service.call('neo-c1', learning_partner_id: learning_partner.id)
    end

    before do
      neo_ai_data.merge!(
        'title' => 'Updated Title',
        'description' => 'Updated description — long enough to satisfy the minimum length validation on Course',
        'modules' => [
          {
            'id' => 'm1',
            'title' => 'Module One Updated',
            'lessons' => [
              {
                'id' => 'l1',
                'title' => 'Lesson One Updated',
                'description' => 'Updated lesson description',
                'estimated_duration' => 120,
                'video_url' => 'https://neo.ai/updated.mp4'
              },
              {
                'id' => 'l2',
                'title' => 'Lesson Two',
                'description' => nil,
                'estimated_duration' => 60,
                'video_url' => 'https://neo.ai/lesson2.mp4'
              }
            ]
          },
          {
            'id' => 'm2',
            'title' => 'Module Two',
            'lessons' => []
          }
        ]
      )
    end

    it 'does not create a duplicate course' do
      expect { service.call('neo-c1', learning_partner_id: learning_partner.id) }
        .not_to change(Course, :count)
    end

    it 'updates title and description' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.title).to eq('Updated Title')
      expect(course.description).to start_with('Updated description')
    end

    it 'updates existing CS modules in place' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.find_by(neo_ai_module_id: 'm1')
      expect(mod.title).to eq('Module One Updated')
    end

    it 'adds new CS modules' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.course_modules.find_by(neo_ai_module_id: 'm2')).to be_present
    end

    it 'updates existing CS lessons in place' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.find_by(neo_ai_module_id: 'm1')
      lesson = mod.lessons.find_by(neo_ai_lesson_id: 'l1')
      expect(lesson.title).to eq('Lesson One Updated')
      expect(lesson.duration).to eq(120)
    end

    it 'adds new CS lessons' do
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.find_by(neo_ai_module_id: 'm1')
      expect(mod.lessons.find_by(neo_ai_lesson_id: 'l2')).to be_present
    end

    it 'destroys CS modules removed from the API' do
      neo_ai_data['modules'].reject! { |m| m['id'] == 'm1' }
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.course_modules.find_by(neo_ai_module_id: 'm1')).to be_nil
    end

    it 'destroys CS lessons removed from the API' do
      neo_ai_data['modules'].first['lessons'].reject! { |l| l['id'] == 'l1' }
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      mod = course.course_modules.find_by(neo_ai_module_id: 'm1')
      expect(mod.lessons.find_by(neo_ai_lesson_id: 'l1')).to be_nil
    end

    it 'preserves Blackboard-added modules' do
      bb_module = existing_course.course_modules.create!(title: 'Blackboard Module')
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(course.course_modules.find_by(id: bb_module.id)).to be_present
    end

    it 'preserves Blackboard-added lessons' do
      mod = existing_course.course_modules.find_by(neo_ai_module_id: 'm1')
      bb_lesson = create(:lesson, course_module: mod)
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      updated_mod = course.course_modules.find_by(neo_ai_module_id: 'm1')
      expect(updated_mod.lessons.find_by(id: bb_lesson.id)).to be_present
    end

    it 'places CS modules before Blackboard-added modules in ordering' do
      bb_module = existing_course.course_modules.create!(title: 'Blackboard Module')
      course = service.call('neo-c1', learning_partner_id: learning_partner.id)
      cs_ids = course.course_modules.where.not(neo_ai_module_id: nil).ids
      expect(course.course_modules_in_order).to eq(cs_ids + [bb_module.id])
    end

    it 'does not change the level tag on re-save' do
      service.call('neo-c1', learning_partner_id: learning_partner.id)
      expect(existing_course.reload.tags.select(&:level?).map(&:name)).to contain_exactly('Beginner')
    end
  end
end
