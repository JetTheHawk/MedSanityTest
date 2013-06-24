require 'watir-webdriver'
require 'watir-webdriver-performance'
require 'win32ole'
require 'fileutils'
require 'rubygems'
class MedTestCase
  def initialize(testId, testDesc, passed)
		@runId = ""
		@testId = testId	
		@testDesc = testDesc
		@start_time = nil
		@end_time = nil
		@browser = nil
		@passed = passed
		@shot_id = nil
		@shot_source = nil
		@performance = ""
		@test_data_hash = {}
		@performance_hash ={}
		@casename = ""
	end
	
	def startTest(casename)
		setStart()
		setBrowser()
		setStepDataValues(casename)
		setRunId
		$log.info(@browser)
	end
	
	def setRunId
		@runId = "#{@testId}.#{@start_time}"
	end
	
	def takeShot
		@time = Time.now.strftime("%m.%d.%Y %H.%M.%S")
		@shot_id = "#{@testid} #{@passed} #{@time}"
		@shot_source = $FolderPath + "\\" + @shot_id + ".png"
		$browser.screenshot.save @shot_source
	end
	
	def getShotId
		return @shot_id
	end
	
	def getShotSource
		return @shot_source
	end
	
	def getEnd
		return @end_time
	end
	
	def setEnd()
		@end_time = Time.now.strftime("%m.%d.%Y %H.%M.%S")
	end
	
	def getStart
		return @start_time
	end
	
	def setStart()
		@start_time = Time.now.strftime("%m.%d.%Y %H.%M.%S")
	end
	
	def getId
		return @testId
	end
	
	def setId(newId)
		@testId = newId
	end
	
	def setBrowser()
		@browser = $browser.driver.browser
	end
	
	def getBrowser
		return @browser
	end
	
	def setStatus(status)
		@passed = status
	end
	
	def getStatus
		return @passed
	end	
	
	def setPerformance
		@performance_hash = $browser.performance.summary
	end
	
	def getPerformance
		return @performance_hash
	end	
	
	def setStepDataValues(casename)
		@casename = casename
		$oci.exec("select DATA_ID, DATA_VALUE from SANITY_TEST_DATA WHERE CASE_NAME='#{@casename}' OR CASE_NAME='global'") do |key, value|
		  @test_data_hash[key] = value
		end
		return @test_data_hash
	end
	
	def getDataValue(dataId)
		return @test_data_hash[dataId]
	end
	
	def testDetermine(status)
		# chkBrow = @browser.to_s()
		# if not chkBrow.include? "internet_explorer"
			# setPerformance
		# end
		if status == false
			setEnd()
			setStatus(status)
			takeShot
			insertResults()
			$log.info("test failed results logged W/O performance")
		else
			$log.info("SETTTING performance...")
			setPerformance
			$log.info("Performance set successfully")
			setEnd()
			setStatus(status)
			takeShot
			insertResults()
			$log.info("test Passed results logged W/ performance")
		end
	end
	
	def insertResults()
		$oci.exec("INSERT INTO SANITY_TEST_RESULTS VALUES ('#{@runId}', '#{@testId}', '#{@testDesc}', '#{@start_time}', '#{@end_time}', '#{@passed}', '#{@shot_id}', '#{@shot_source}', '#{@browser}', '#{@performance_hash[:app_cache]}', '#{@performance_hash[:dns]}', '#{@performance_hash[:tcp_connection]}', '#{@performance_hash[:request]}', '#{@performance_hash[:response]}', '#{@performance_hash[:dom_processing]}', '#{@performance_hash[:time_to_first_byte]}', '#{@performance_hash[:time_to_last_byte]}', '#{@performance_hash[:response_time]}' )")
		$oci.commit
	end
	
end
