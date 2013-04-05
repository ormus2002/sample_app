#require 'spec_helper'

#describe "UsersPages" do
#  describe "GET /users_pages" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get users_pages_index_path
#      response.status.should be(200)
#    end
#  end
#end

require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Регистрация') }
    it { should have_selector('title', text: full_title('Регистрация')) }
  end
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end
  
  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Зарегистрироваться" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Регистрация') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Имя",            with: "Example User"
        fill_in "Е-мейл",         with: "user@example.com"
        fill_in "Пароль",         with: "foobar"
        fill_in "Подтверждение",  with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Добро пожаловать') }
        it { should have_link('Выход') }
      end
    end
  end
  
end
