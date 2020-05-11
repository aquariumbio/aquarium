# typed: true
# frozen_string_literal: true

class UserAgreement
  attr_reader :title, :update_date, :clauses

  def initialize(title:, update_date:, clauses:)
    @title = title
    @update_date = update_date
    @clauses = clauses
  end

  def to_s
    "{ title: #{@title}, date: #{@update_date}, clauses: #{clauses} }"
  end

  def self.create_from(user_agreement)
    UserAgreement.new(
      title: user_agreement[:title],
      update_date: user_agreement[:updated],
      clauses: user_agreement[:clauses]
    )
  end
end
