require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
      # @host = host || "https://vast-shore-6088.herokuapp.com"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
      [:browse_loan_requests, :sign_up_as_lender, :sign_up_as_borrower,
       :user_browses_categories,:user_browses_loan_request_from_category,
       :borrower_creates_loan_request,:lender_lends,:visit_404_page]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_link("Login")
      session.fill_in("session_email", with: email)
      session.fill_in("session_password", with: pw)
      session.click_link_or_button("Log In")
    end

    def browse_loan_requests
      session.visit("#{host}/browse")
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def user_browses_categories
      log_in
      session.visit("#{host}/categories")
      session.all(".lr-about").sample.click
    end

    def user_browses_loan_request_from_category
      log_in
      session.visit("#{host}/categories")
      session.all(".lr-about").sample.click
      session.all(".lr-about").sample.click
    end

    def borrower_creates_loan_request
      sign_up_as_borrower
      session.click_link_or_button("Create Loan Request")
      session.within("#loanRequestModal") do
        session.fill_in("Title", with: "Basketball Court")
        session.fill_in("Description", with: "Court for the kids")
        session.fill_in("Image url", with: "")
        session.fill_in("Requested by date", with: "10/10/2015")
        session.fill_in("Repayment begin date", with: "12/10/2015")
        session.select("Monthly", from: "Repayment rate")
        session.select("Education", from: "Category")
        session.fill_in("Amount", with: "100")

        session.click_link_or_button "Submit"
      end

    end

    def lender_lends
      begin
        sign_up_as_lender
        session.visit "#{host}/browse"
        session.all(".lr-about").sample.click
        session.find(".btn-contribute").click
        session.visit "#{host}/cart"
        session.find(".cart-button").click
      rescue
        retry while true
      end
    end

    def visit_404_page
      log_in
      session.visit("#{host}/browse")
      session.visit("#{host}/monkeys39202")
      session.click_on("Home")

    end

    def categories
      ["Agriculture", "Education", "Youth","Transportation"]
    end
  end
end
