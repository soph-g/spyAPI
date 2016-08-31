require 'rails_helper'

feature 'spyAPI' do
  context 'no API key is given' do
    scenario 'error message is returned when no API key is given' do
      visit '/apis?'
      expect(page).to have_content('{"message":"No API Key found in headers, body or querystring"}')
    end
  end
  context 'API key is given' do
    before do
      sign_up
      api = Api.create(key: 'abcdefghijklmnopqrstuvwxyz0123456789', user_id: User.last.id)
      Json.create(name: 'test-data', content: "Hello, World!", api_id: api.id)
    end
    scenario 'JSON is returned' do
      visit '/apis?api-key=abcdefghijklmnopqrstuvwxyz0123456789&json=test-data'
      expect(page).to have_content('Hello, World!')
      expect(page).not_to have_content('{"message":"No API Key found in headers, body or querystring"}')
    end
  end
  context 'API key is given' do
    before do
      sign_up
      api = Api.create(key: 'abcdefghijklmnopqrstuvwxyz0123456789', user_id: User.last.id)
      Json.create(name: 'test-data', content: "Hello, World!", api_id: api.id)
      Json.create(name: 'test-data2', content: "Hello, World, again!", api_id: api.id)
    end

    scenario 'specific JSON is returned' do
      visit '/apis?api-key=abcdefghijklmnopqrstuvwxyz0123456789&json=test-data2'
      expect(page).to have_content('Hello, World, again!')
      expect(page).not_to have_content('{"message":"No API Key found in headers, body or querystring"}')
    end
  end

  context 'User is able to view their own API' do
    before do
      sign_up
      click_link 'add API'
      fill_in 'Name', with: 'Test API'
      click_button 'Create Api'
    end

    scenario ' User can see their own API' do
      expect(page).to have_content('Test API')
      expect(current_path).to eq ('/')
    end

    scenario ' User cannot see another users API' do
      sign_out
      sign_up(email: 'another@test.com')
      click_link 'add API'
      fill_in 'Name', with: 'Second API'
      click_button 'Create Api'
      expect(page).to have_content('Second API')
      expect(page).not_to have_content('Test API')
      expect(current_path).to eq ('/')
    end


  end
end
