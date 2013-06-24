require 'watir-webdriver'
ENV['no_proxy'] = '127.0.0.1'

$browser = Watir::Browser.new :ie
#$browser.goto 'http://www.medline.com'

#require 'watir'
require 'rubygems'
require 'log4r'
require 'test/unit'
require 'win32ole'
require 'fileutils'
require_relative 'MedTestCase'
require 'oci8'
require 'dbi'
#require 'logger'
include Log4r

$oci = OCI8.new('####','#######','###########')

class TC_Login < Test::Unit::TestCase

  def setupLogger()
       $log = Logger.new 'log'
       $log.outputters = Outputter.stdout
	   @pathh = $logpath.to_s()
       $file = FileOutputter.new('fileOutputter', :filename => @pathh,:trunc => false)
       $format = PatternFormatter.new( :pattern => "[%l] %d :: %m")

       $file.formatter = $format
       # log level order is DEBUG < INFO < WARN < ERROR < FATAL
       $log.level = Log4r::INFO
       $log.add($file)  
	end
	
	def newFolder()
		time = Time.now.strftime("%m.%d.%Y %H.%M.%S")
		$FolderStamp = "ScreenLogs" + time
		$FolderPath = "C:\\Users\\##############\\" + $FolderStamp
		FileUtils.mkdir $FolderStamp
		$logpath = $FolderPath.to_s() + "\\regressionLog.log"	
	end
	
	def startup()
		newFolder()
		setupLogger()
	end   
	
	def test1_1_1_nav_to_login_atgtest_np
		startup()
		$log.info("")
		$log.info("#test1_1_1 Case ISA No Price - navigate to login")
		begin
			test1_1_1 = MedTestCase.new('1_1_1', 'Navigate to login screen on medline.com', nil)
			test1_1_1.startTest("test1_1_1")
			$browser.goto test1_1_1.getDataValue("test_home_url")
			
			begin
				$browser.a(:text => test1_1_1.getDataValue("test_market_nothanks")).click
			rescue
				$log.info("no area of interest box")
			end
			
			$browser.a(:text => test1_1_1.getDataValue("test_login_link")).click
			$browser.text_field(:name => test1_1_1.getDataValue("test_login_textfield")).wait_until_present
			if $browser.text_field(:name => test1_1_1.getDataValue("test_login_textfield")).exists?
				$log.info("PASSED. Navigated to login page")
				test1_1_1.testDetermine(true)
			else
				$log.info("FAILED to nav to login page")
				test1_1_1.testDetermine(false)
			end
		rescue TimeoutError => e
			$log.info("waiting timed out, click and wait again...")
			$browser.a(:text => test1_1_1.getDataValue("test_login_link")).click
			$browser.text_field(:name => test1_1_1.getDataValue("test_login_textfield")).wait_until_present
		end
	end
	
	def test1_1_2_login_atgtest_np
		$log.info("")
		$log.info("#test1_1_2 Case ISA No Price - Enter credentials and login")
		begin
			test1_1_2 = MedTestCase.new('1_1_2', 'Enter credentials and login', nil)
			test1_1_2.startTest("test1_1_2")
			
			$browser.text_field(:name => test1_1_2.getDataValue("test_login_textfield")).set test1_1_2.getDataValue("test1_1_2_user")
			$browser.text_field(:name => test1_1_2.getDataValue("test_pwd_textfield")).set test1_1_2.getDataValue("test1_1_2_pwd")
			$browser.span(:text=> test1_1_2.getDataValue("test_login_link")).click
			$browser.a(:text => test1_1_2.getDataValue("test1_1_2_linkText")).click
			$browser.frameset(:id => "isaTopFS").frame(:name => "isaTop").frameset(:id => "mainFS").frame(:name => "header").div(:id => "account-info-header").div(:id => "account-info-header-inner").wait_until_present
			if $browser.frameset(:id => "isaTopFS").frame(:name => "isaTop").frameset(:id => "mainFS").frame(:name => "header").div(:id => "account-info-header").div(:id => "account-info-header-inner").exists?
				$log.info("PASSED. logged into my account page")
				test1_1_2.testDetermine(true)
			else
				$log.info("FAILED to login")
				test1_1_2.testDetermine(false)
			end
		rescue 
			$log.info("test1_1_2 received an error")
			test1_1_2.testDetermine(false)
		end
	end
