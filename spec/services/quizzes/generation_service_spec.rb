# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quizzes::GenerationService do
  let(:service) { described_class.new(course_module) }
  let(:course_module) { instance_double(CourseModule) }
  let(:lesson_one) { instance_double(Lesson, title: 'Lesson 1', local_contents: [local_content_one]) }
  let(:lesson_two) { instance_double(Lesson, title: 'Lesson 2', local_contents: [local_content_two]) }
  let(:local_content_one) { instance_double(LocalContent, transcripts: [transcript_one]) }
  let(:local_content_two) { instance_double(LocalContent, transcripts: [transcript_two]) }
  let(:transcript_one) { instance_double(Transcript, text: 'First transcript') }
  let(:transcript_two) { instance_double(Transcript, text: 'Second transcript') }

  before do
    allow(course_module).to receive_message_chain(:lessons, :includes).and_return([lesson_one, lesson_two]) # rubocop:disable RSpec/MessageChain
    allow(local_content_one.transcripts).to receive(:pluck).with(:text).and_return(['First transcript'])
    allow(local_content_two.transcripts).to receive(:pluck).with(:text).and_return(['Second transcript'])
    allow(course_module).to receive(:quizzes).and_return([])
  end

  describe '#initialize' do
    it 'sets course_module and transcripts' do
      summarized_transcripts = [{ title: lesson_one.title, transcripts: transcript_one.text },
                                { title: lesson_two.title, transcripts: transcript_two.text }]
      expect(service.course_module).to eq(course_module)
      expect(service.transcripts).to eq(summarized_transcripts)
    end
  end

  describe '#generate_via_ai' do
    let(:llm_instance) { instance_double(Integrations::Llm::Gemini) }
    let(:result) { instance_double(Result, ok?: true, data: { 'quizzes' => %w[quiz1 quiz2] }) }

    before do
      allow(Integrations::Llm::Api).to receive(:llm_instance).with(provider: :gemini).and_return(llm_instance)
      allow(llm_instance).to receive(:generate_quiz).with(5, service.transcripts).and_return(result)
    end

    it 'returns quizzes if result is ok' do
      expect(service.generate_via_ai).to eq(%w[quiz1 quiz2])
    end

    it 'returns [] and logs error if result is not ok' do
      allow(result).to receive(:ok?).and_return(false)
      allow(Rails.logger).to receive(:error)
      expect(service.generate_via_ai).to eq([])
      expect(Rails.logger).to have_received(:error).with("Quiz generation failed: #{result.data}")
    end

    it 'returns [] if transcripts are empty' do
      allow(service).to receive(:transcripts).and_return([])
      expect(service.generate_via_ai).to eq([])
    end
  end

  describe '#max_quiz_reached?' do
    it 'returns true if quiz count >= MAX_QUIZ_QUESTIONS' do
      allow(course_module).to receive(:quizzes).and_return(%w[q1 q2 q3 q4 q5])
      expect(service.max_quiz_reached?).to be true
    end

    it 'returns false if quiz count < MAX_QUIZ_QUESTIONS' do
      allow(course_module).to receive(:quizzes).and_return(%w[q1 q2])
      expect(service.max_quiz_reached?).to be false
    end
  end

  describe '#generate?' do
    it 'returns true if transcripts present and not maxed out' do
      allow(course_module).to receive(:quizzes).and_return([])
      expect(service.generate?).to be true
    end

    it 'returns false if transcripts blank' do
      allow(course_module).to receive_message_chain(:lessons, :includes).and_return([]) # rubocop:disable RSpec/MessageChain
      expect(service.generate?).to be false
    end

    it 'returns false if max quiz reached' do
      allow(course_module).to receive(:quizzes).and_return(%w[q1 q2 q3 q4 q5])
      expect(service.generate?).to be false
    end
  end

  describe '#tooltip' do
    it 'returns transcripts_missing if transcripts blank' do
      allow(course_module).to receive_message_chain(:lessons, :includes).and_return([]) # rubocop:disable RSpec/MessageChain
      expect(service.tooltip).to eq('quiz.generate.transcripts_missing')
    end

    it 'returns too_many_questions if max quiz reached' do
      allow(course_module).to receive(:quizzes).and_return(%w[q1 q2 q3 q4 q5])
      expect(service.tooltip).to eq('quiz.generate.too_many_questions')
    end

    it 'returns button if ready to generate' do
      expect(service.tooltip).to eq('quiz.generate.button')
    end
  end
end
