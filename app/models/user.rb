class User < ApplicationRecord
  has_many :organization_users
  has_many :organizations, through: :organization_users
  has_many :division_users
  has_many :divisions, through: :division_users
  belongs_to :role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, presence: true, length: {maximum: 25}
  validates :role, :sex, presence: true
  validates :organizations, presence: true, if: :teacher?
  validates :divisions, presence: true, if: :teacher?
  validates :organizations, presence: true, if: :learner?
  validates :divisions, presence: true, length: {maximum: 1, minimum: 1}, if: :learner?

  before_validation :set_role, on: :create

  def name
    "#{self.first_name} #{self.last_name} #{self.patronymic}"
  end

  def short_name
    "#{self.last_name} #{self.first_name.first}. "
  end

  def sex_label
    sex ? "мужской" : "женский"
  end

  def admin?
    self.role == Role.admin
  end

  def teacher?
    self.role == Role.teacher
  end

  def learner?
    self.role == Role.learner
  end

  def destroy_organizations
    self.organizations.destroy_all
  end

  def destroy_divisions
    self.divisions.destroy_all
  end

  def set_role
    self.role = Role.learner if self.role.blank?
  end
end
