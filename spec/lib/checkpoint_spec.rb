require 'spec_helper'
describe AbacosIntegrationMonitor::Checkpoint do

  let(:checkpoint) {AbacosIntegrationMonitor::Checkpoint.instance}
  
  before :each do
    @file = mock('checkpoint')
    @file.stub(:readlines).and_return(["^HEAD 23/09/2012-14:06:28 24/09/2012-23:18:05 529 FAILED"])
  end

  it "should have a filename called checkpoint" do 
    pending
  end

  context "when reloading" do 
    it "should read the checkpoint file content" do
      checkpoint.should_receive(:parse_file)
      checkpoint.reload!
    end

    it "should clear the integration_records" do
      pending
    end

    it "should clear the head" do
      pending
    end

  end

  context "when parsing the checkpoint file" do
    
    it "should raise an error if empty" do
      File.should_receive(:open).with(checkpoint.file_path).and_return(@file)
      @file.stub(:readlines).and_return([])
      expect{checkpoint.parse_file}.to raise_error(RuntimeError, /file is empty/)
    end

    it "should raise an error if there is no ^HEAD" do
      File.should_receive(:open).with(checkpoint.file_path).and_return(@file)
      @file.stub(:readlines).and_return(["0 23/09/2012-14:06:28 24/09/2012-23:18:05 529 FAILED"])
      expect{checkpoint.parse_file}.to raise_error(RuntimeError, /Error parsing file/)
    end

    it "should not raise an error with a good checkpoint file" do
      File.should_receive(:open).with(checkpoint.file_path).and_return(@file)
      expect{checkpoint.parse_file}.to_not raise_error
    end


    it "each line should be related to a OrderIntegrationRecord" do
      pending
    end


    it "should read the checkpoint file and transform it on an array of records" do
      pending 
    end
  end


  it "should write atomically to the checkpoint file" do
    pending
  end


end