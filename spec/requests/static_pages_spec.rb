#require 'spec_helper'

#describe "StaticPages" do
#  describe "GET /static_pages" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get static_pages_index_path
#      response.status.should be(200)
#    end
#  end
#end

require 'spec_helper'

describe "Static pages" do
  
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
  
  describe "Home page" do
    before { visit root_path }
    
    let(:heading)    { 'Пример' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"
    
    it { should_not have_selector('title', text: '| Начало') }
  end

  describe "Help page" do
    before { visit help_path }

    let(:heading)    { 'Помощь' }
    let(:page_title) { 'Помощь' }
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    
    let(:heading)    { 'О нас' }
    let(:page_title) { 'О нас' }
    it_should_behave_like "all static pages"
  end
  
  describe "Contact page" do
    before { visit contact_path }

    let(:heading)    { 'Контакты' }
    let(:page_title) { 'Контакты' }
    it_should_behave_like "all static pages"
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "О нас"
    page.should have_selector 'title', text: full_title('О нас')
    click_link "Помощь"
    page.should have_selector 'title', text: full_title('Помощь')
    click_link "Контакты"
    page.should have_selector 'title', text: full_title('Контакты')
    click_link "Начало"
    click_link "Зарегистрироваться!"
    page.should have_selector 'title', text: full_title('Регистрация')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
end

