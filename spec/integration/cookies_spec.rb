require 'spec_helper'

describe Capybara::Driver::Akephalos do
  context 'with akephalos driver' do

    let(:driver) { Capybara::Driver::Akephalos.new(Application) }
    after { driver.reset! }

    describe "#cookies" do
      context "when no cookies are set" do
        it "returns an empty array" do
          driver.cookies.should be_empty
        end
      end

      context "when cookies are set" do
        before { driver.visit("/set_cookie") }

        it "returns the cookies" do
          driver.cookies.should_not be_empty
        end

        describe "#cookies.each" do
          it "yields cookie objects" do
            yielded = false
            driver.cookies.each { yielded = true }
            yielded.should be_true
          end
        end

        describe "#cleanup!" do
          it "clears the cookies" do
            driver.cleanup!
            driver.cookies.should be_empty
          end
        end

        describe "#cookies.delete" do
          it "removes the cookie from the sesison" do
            driver.cookies.delete(driver.cookies["capybara"])
            driver.cookies.should be_empty
          end
        end

        describe "#cookies[]" do
          context "when the cookie exists" do
            it "returns the named cookie" do
              driver.cookies["capybara"].should_not be_nil
            end

            context "the cookie" do
              let(:cookie) { driver.cookies["capybara"] }
              it "includes the name" do
                cookie.name.should == "capybara"
              end

              it "includes the domain" do
                cookie.domain.should == "localhost"
              end

              it "includes the path" do
                cookie.path.should == "/"
              end

              it "includes the value" do
                cookie.value.should == "test_cookie"
              end

              it "includes the expiration" do
                cookie.expires.should be_nil
              end

              it "includes security" do
                cookie.should_not be_secure
              end
            end

          end
          context "when the cookie does not exist" do
            it "returns nil" do
              driver.cookies["nonexistant"].should be_nil
            end
          end
        end

      end
    end

  end
end

