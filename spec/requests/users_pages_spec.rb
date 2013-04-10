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
    
    before do
      sign_in user
      visit user_path(user)
    end

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }

      it { should have_link('Удалить'), href: micropost_path(m1) }
      
      describe "delete links" do
        let(:user2) { FactoryGirl.create(:user) }
        before do
          sign_in user2
          visit user_path(user) 
        end
        it { should_not have_link('Удалить') }
      end

      describe "pagination" do

        before(:all) { 35.times { FactoryGirl.create(:micropost, user: user) } }
        after(:all)  { Micropost.delete_all }

        it { should have_selector('div.pagination') }

        it "should list each micropost" do
          Micropost.paginate(page: 1).each do |micropost|
            page.should have_selector('li', text: micropost.content)
          end
        end
      end
      
    end
    
    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Читать"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Читать"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Читать" }
          it { should have_selector('input', value: 'Читаю') }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Читаю"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Читаю"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Читаю" }
          it { should have_selector('input', value: 'Читать') }
        end
      end
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
  
  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Читаемые')) }
      it { should have_selector('h3', text: 'Читаемые') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Читатели')) }
      it { should have_selector('h3', text: 'Читатели') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
