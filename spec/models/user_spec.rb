require 'rails_helper'

RSpec.describe User, type: :model do
  let(:admin) { FactoryGirl.create(:admin) }

  it "ユーザの項目 メールアドレス、パスワード、送付先情報（名前、住所）" do
    is_expected.to respond_to(:email)
    is_expected.to respond_to(:encrypted_password)
    is_expected.to respond_to(:to_name)
    is_expected.to respond_to(:to_address)
  end
  
  before do
    @user = User.new(
      name: "Example User", 
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    )
  end

  subject { @user }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should be_valid }

  describe "初期値確認" do
    it "管理者権限がないこと" do
      expect(@user.admin).to be_falsey
    end
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  #describe "when name is too long" do
  #before { @user.name = "a" * 51 }
  #it { should_not be_valid }
  #end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. 
        foo@bar_baz.com foo@baz+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        #expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
end
