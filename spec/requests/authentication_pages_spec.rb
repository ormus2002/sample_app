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
      it { should_not have_link('Пользователи', href: users_path) }
      it { should_not have_link('Профиль') }
      it { should_not have_link('Настройки') }
      it { should_not have_link('Выход',        href: signout_path) }
      it { should have_link('Войти', href: signin_path) }
      
      describe "after visiting another page" do
        before { click_link "Начало" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_selector('title',    text: user.name) }
      it { should have_link('Пользователи', href: users_path) }
      it { should have_link('Профиль',      href: user_path(user)) }
      it { should have_link('Настройки',    href: edit_user_path(user)) }
      it { should have_link('Выход',        href: signout_path) }
      it { should_not have_link('Войти', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Выход" }
        it { should have_link('Войти') }
      end
    end
    
  end
  
  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Вход') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
        
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Вход') }
        end
        
        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('title', text: 'Вход') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('title', text: 'Вход') }
        end
      end
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Е-мейл",    with: user.email
          fill_in "Пароль", with: user.password
          click_button "Войти"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Редактирование пользователя')
          end
          
          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Е-мейл",    with: user.email
              fill_in "Пароль", with: user.password
              click_button "Войти"
            end

            it "should render the default (profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
        
      end
      
      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end
      
      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end
      
    end
    
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Редактирование пользователя')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as signed user" do
      let(:user) { FactoryGirl.create(:user) }
      
      before { sign_in user }

      describe "submitting a GET request to the Users#new action" do
        before { get new_user_path }
        specify { response.should redirect_to(root_path) }
      end
      
      describe "submitting a POST request to the Users#create action" do
        before { post users_path }
        specify { response.should redirect_to(root_path) }
      end
    end
    
  end
  
end
