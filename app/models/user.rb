class User < ApplicationRecord
  require 'csv'
  has_many :attendances, dependent: :destroy
  has_many :requested_attendances, class_name: 'Attendance', foreign_key: 'superior_id'  # 追加
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..50 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence:true, length: { minimum: 6 }, allow_nil: true
  
  enum role: { general: 0, superior: 1, admin_role: 2 }
  
  def overtime_notifications_count
    # この例では、attendanceが承認待ちのものをカウントしています。
    # 必要に応じて適切な条件を設定してください。
    self.attendances.where(status: "pending").count
  end
  
  def unconfirmed_overtime_changes_count
    attendances.where(overtime_changed: true).count
  end
  
  def unconfirmed_overtime_changes_from_other_superior
    # 上長Aと上長BのIDを定義 (ここは実際のIDに変更してください)
    superior_a_id = 1
    superior_b_id = 2
  
    # 現在のユーザーが上長Aなら上長Bから、上長Bなら上長Aからの承認待ちの申請を取得
    if self.id == superior_a_id
      attendances.where(overtime_notified: false, approved_by_id: superior_b_id).count
    elsif self.id == superior_b_id
      attendances.where(overtime_notified: false, approved_by_id: superior_a_id).count
    else
      0  # 一般ユーザーの場合は0を返す
    end
  end

  
  def self.import(file)
    success_count = 0
    failure_count = 0
    
    CSV.open(file.path, 'r:bom|utf-8', headers: true) do |csv|
        csv.each do |row|
            user_hash = row.to_hash
      
        # 入力データのバリデーションチェック
        if user_hash['name'].blank? || user_hash['email'].blank? || user_hash['password'].blank?
          Rails.logger.warn("Invalid data: #{user_hash.inspect}")
          failure_count += 1
          next
        end

        begin
          # 新しいレコードを初期化するか、既存のレコードを見つける
          user = find_or_initialize_by(email: user_hash['email'])
          
          # ユーザーの属性を設定
          user.name = user_hash['name']
          user.email = user_hash['email']
          user.password = user_hash['password']
          # 他の属性も同様にここに設定します
          
          # ユーザーを保存
          if user.save
            success_count += 1
          else
            Rails.logger.warn("Failed to save user #{user_hash['email']}: #{user.errors.full_messages.join(', ')}")
            failure_count += 1
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn("Failed to create or update user from row #{user_hash.inspect}: #{e.message}")
          failure_count += 1
        end
      end
    end
    
    return { success: success_count, failure: failure_count }
  end
  
  def self.working_users
    where(is_working: true, admin: false)
  end
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # 検索のためのメソッド
  scope :search_by_name, -> (name) {
    where('name LIKE ?', "%#{name}%") if name.present?
  }
end
