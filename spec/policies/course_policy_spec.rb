# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursePolicy do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }
  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :manager, team:, learning_partner: }
  let(:creator_manager) { create :user, :manager, team:, learning_partner:, content_studio_creator: true }

  let(:course) { create :course, learning_partner: }
  let(:cs_course) { create :course, learning_partner:, neo_ai_course_id: 'neo-123' }
  let(:other_lp_cs_course) { create :course, neo_ai_course_id: 'neo-456' }

  before do
    create :payment_plan, learning_partner:, content_studio_enabled: true
  end

  describe '#manage?' do
    it 'permits admin' do
      expect(described_class.new(admin, nil)).to be_manage
    end

    it 'permits manager of CS-enabled LP' do
      expect(described_class.new(manager, nil)).to be_manage
    end

    it 'permits content_studio_creator manager of CS-enabled LP' do
      expect(described_class.new(creator_manager, nil)).to be_manage
    end

    it 'denies manager whose LP does not have content studio enabled' do
      other_lp = create :learning_partner
      other_team = create :team, learning_partner: other_lp
      non_cs_manager = create :user, :manager, team: other_team, learning_partner: other_lp
      expect(described_class.new(non_cs_manager, nil)).not_to be_manage
    end
  end

  describe '#show?' do
    context 'with admin' do
      it 'permits any course' do
        expect(described_class.new(admin, course)).to be_show
      end
    end

    context 'with manager of CS-enabled LP' do
      it 'permits own LP CS course even when unpublished' do
        expect(described_class.new(manager, cs_course)).to be_show
      end

      it 'permits creator manager on own LP CS course' do
        expect(described_class.new(creator_manager, cs_course)).to be_show
      end

      it 'denies CS course from a different LP' do
        expect(described_class.new(manager, other_lp_cs_course)).not_to be_show
      end

      it 'denies regular (non-CS) unpublished course' do
        expect(described_class.new(manager, course)).not_to be_show
      end
    end
  end

  describe '#edit?' do
    it 'permits admin' do
      expect(described_class.new(admin, course)).to be_edit
    end

    it 'denies manager' do
      expect(described_class.new(manager, course)).not_to be_edit
    end

    it 'denies content_studio_creator manager on own CS course' do
      expect(described_class.new(creator_manager, cs_course)).not_to be_edit
    end
  end

  describe '#update?' do
    it 'permits admin' do
      expect(described_class.new(admin, course)).to be_update
    end

    it 'denies manager' do
      expect(described_class.new(manager, course)).not_to be_update
    end

    it 'denies content_studio_creator manager on own CS course' do
      expect(described_class.new(creator_manager, cs_course)).not_to be_update
    end
  end

  describe '#destroy?' do
    it 'permits admin for unpublished course with no enrollments' do
      expect(described_class.new(admin, course)).to be_destroy
    end

    it 'denies manager' do
      expect(described_class.new(manager, course)).not_to be_destroy
    end

    it 'denies content_studio_creator manager on own CS course' do
      expect(described_class.new(creator_manager, cs_course)).not_to be_destroy
    end
  end

  describe '#publish?' do
    it 'denies everyone when course is already published' do
      published_course = create :course, :published, learning_partner: learning_partner
      expect(described_class.new(admin, published_course).publish?).to be false
      expect(described_class.new(creator_manager, published_course).publish?).to be false
    end

    it 'denies when course is not ready to publish' do
      expect(described_class.new(admin, course).publish?).to be false
    end

    it 'permits content_studio_creator manager on own ready CS course' do
      ready_cs_course = course_with_associations(published: false)
      ready_cs_course.update!(neo_ai_course_id: 'neo-ready', learning_partner:)
      expect(described_class.new(creator_manager, ready_cs_course).publish?).to be true
    end

    it 'denies plain manager on own LP CS course' do
      ready_cs_course = course_with_associations(published: false)
      ready_cs_course.update!(neo_ai_course_id: 'neo-ready', learning_partner:)
      expect(described_class.new(manager, ready_cs_course).publish?).to be false
    end
  end

  describe '#unpublish?' do
    let(:published_cs_course) { create :course, :published, learning_partner:, neo_ai_course_id: 'neo-pub' }

    it 'permits admin on published course' do
      expect(described_class.new(admin, published_cs_course).unpublish?).to be true
    end

    it 'permits content_studio_creator manager on own published CS course' do
      expect(described_class.new(creator_manager, published_cs_course).unpublish?).to be true
    end

    it 'denies plain manager on own LP published CS course' do
      expect(described_class.new(manager, published_cs_course).unpublish?).to be false
    end

    it 'denies when course is not published' do
      expect(described_class.new(admin, cs_course).unpublish?).to be false
    end
  end
end
