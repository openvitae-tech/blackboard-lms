# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quizzes::GenerationService, type: :service do
  let(:course) { create(:course) }
  let(:course_module) { create(:course_module, course: course) }

  let!(:lesson_intro) { create(:lesson, course_module: course_module, title: 'Introduction') }
  let!(:lesson_summary) { create(:lesson, course_module: course_module, title: 'Summary') }

  # Use existing local_content if the lesson factory created one already
  let!(:intro_local_content) do
    lesson_intro.local_contents.first || create(:local_content, lesson: lesson_intro)
  end

  let!(:summary_local_content) do
    lesson_summary.local_contents.first || create(:local_content, lesson: lesson_summary)
  end

  let!(:intro_transcript) do
    create(:transcript, local_content: intro_local_content, text: 'This is the introduction transcript', start_at: 0,
                        end_at: 1000)
  end

  let!(:summary_transcript) do
    create(:transcript, local_content: summary_local_content, text: 'This is the summary transcript', start_at: 0,
                        end_at: 1000)
  end

  describe 'summarization' do
    it 'builds summarized transcripts from lessons -> local_contents -> transcripts' do
      service = described_class.new(course_module)
      expect(service.transcripts).to contain_exactly(
        { title: lesson_intro.title, transcripts: intro_transcript.text },
        { title: lesson_summary.title, transcripts: summary_transcript.text }
      )
    end
  end

  describe '#generate_via_ai' do
    # use a plain double so we won't enforce real method arity/signature
    let(:llm_instance) { instance_double(Integrations::Llm::Gemini) }
    let(:result) { instance_double(Result, ok?: true, data: { 'quizzes' => %w[q1 q2] }) }

    before do
      allow(Integrations::Llm::Api).to receive(:llm_instance).with(provider: :gemini).and_return(llm_instance)
      allow(llm_instance).to receive(:generate_quiz).and_return(result)
    end

    it 'returns quizzes when LLM returns ok' do
      service = described_class.new(course_module)
      expect(service.generate_via_ai).to eq(%w[q1 q2])
    end

    it 'returns empty array and logs when LLM fails' do
      allow(result).to receive(:ok?).and_return(false)
      allow(Rails.logger).to receive(:error)
      service = described_class.new(course_module)
      expect(service.generate_via_ai).to eq([])
    end
  end

  describe '#generate?, #max_quiz_reached? and #tooltip' do
    it 'returns true when transcripts present and not maxed' do
      service = described_class.new(course_module)
      expect(service.generate?).to be true
    end

    it 'returns false when quizzes count reaches MAX' do
      create_list(:quiz, described_class::MAX_QUIZ_QUESTIONS, course_module: course_module)
      service = described_class.new(course_module)
      expect(service.generate?).to be false
    end
  end

  describe '#tooltip' do
    it 'indicates too many questions when quizzes count reaches MAX' do
      create_list(:quiz, described_class::MAX_QUIZ_QUESTIONS, course_module: course_module)
      service = described_class.new(course_module)
      expect(service.tooltip).to eq('quiz.generate.too_many_questions')
    end

    it 'indicates missing transcripts when none present' do
      empty_module = create(:course_module)
      service = described_class.new(empty_module)
      expect(service.tooltip).to eq('quiz.generate.transcripts_missing')
    end
  end
end
