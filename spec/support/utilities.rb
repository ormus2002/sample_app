include ApplicationHelper

def sign_in(user)
  visit signin_path
  fill_in "Е-мейл",    with: user.email
  fill_in "Пароль", with: user.password
  click_button "Войти"
  # Вход без Capybara.
  cookies[:remember_token] = user.remember_token
end
