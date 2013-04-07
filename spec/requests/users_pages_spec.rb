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

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'Все пользователи') }
    it { should have_selector('h1',    text: 'Все пользователи') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
    
    describe "delete links" do

      it { should_not have_link('Удалить') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('Удалить', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('Удалить') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('Удалить', href: user_path(admin)) }
      end
    end
    
  end
  
  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Регистрация') }
    it { should have_selector('title', text: full_title('Регистрация')) }
  end
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
    
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
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
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1',    text: "Мой профиль") }
      it { should have_selector('title', text: "Редактирование пользователя") }
      it { should have_link('Изменить', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Сохранить" }

      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Имя",             with: new_name
        fill_in "Е-мейл",            with: new_email
        fill_in "Пароль",         with: user.password
        fill_in "Подтверждение", with: user.password
        click_button "Сохранить"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Выход', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end
end
