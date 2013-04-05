require 'spec_helper'

#describe "AuthenticationPages" do
#  describe "GET /authentication_pages" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get authentication_pages_index_path
#      response.status.should be(200)
#    end
#  end
#end

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Вход') }
    it { should have_selector('title', text: 'Вход') }
  end
  
  describe "signin" do
    before { visit signin_path }
      
    describe "with invalid information" do
      before { click_button "Войти" }

      it { should have_selector('title', text: 'Вход') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
      
      describe "after visiting another page" do
        before { click_link "Начало" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Е-мейл",    with: user.email.upcase
        fill_in "Пароль", with: user.password
        click_button "Войти"
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Профиль', href: user_path(user)) }
      it { should have_link('Выход', href: signout_path) }
      it { should_not have_link('Войти', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Выход" }
        it { should have_link('Войти') }
      end
    end
    
  end
end
