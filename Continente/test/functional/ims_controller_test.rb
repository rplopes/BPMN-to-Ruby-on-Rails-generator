require 'test_helper'

class ImsControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get servicedesk_loggingandclassification" do
    get :servicedesk_loggingandclassification
    assert_response :success
  end

  test "should get servicedesk_knowledgedatabasequery" do
    get :servicedesk_knowledgedatabasequery
    assert_response :success
  end

  test "should get infrastructureresponsible_productincidentresolution" do
    get :infrastructureresponsible_productincidentresolution
    assert_response :success
  end

  test "should get suppliersmanager_logisticsincidentresolution" do
    get :suppliersmanager_logisticsincidentresolution
    assert_response :success
  end

  test "should get technicalstaff_technicalincidentresolution" do
    get :technicalstaff_technicalincidentresolution
    assert_response :success
  end

  test "should get boardofdirectors_criticalincidentresolution" do
    get :boardofdirectors_criticalincidentresolution
    assert_response :success
  end

  test "should get servicedesk_resolved" do
    get :servicedesk_resolved
    assert_response :success
  end

  test "should get servicedesk_delegation" do
    get :servicedesk_delegation
    assert_response :success
  end

  test "should get infrastructureresponsible_resolved" do
    get :infrastructureresponsible_resolved
    assert_response :success
  end

  test "should get suppliersmanager_resolved" do
    get :suppliersmanager_resolved
    assert_response :success
  end

  test "should get technicalstaff_resolved" do
    get :technicalstaff_resolved
    assert_response :success
  end

end
