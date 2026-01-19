# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :set_issue

  def new
    authorize @issue
    render partial: "form", locals: { issue: @issue }
  end

  def create
    authorize @issue
    @issue.description = params[:description]    
    if @issue.save && @issue.question.report!
      flash[:success] = I18n.t('question.issue.created')
    end
  end

  private

  def set_issue
    @issue = Issue.find_or_initialize_by(user: current_user, question_id: params[:question_id])
    Rails.logger.info(@issue.inspect)
  end
end