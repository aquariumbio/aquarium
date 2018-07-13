# require_relative 'show_response'
require 'rails_helper'
require '/aquarium/lib/krill/show_response'
include Krill
# require_relative '../models/operation'

RSpec.describe ShowResponse do
	resp = ShowResponse.new({
		table_inputs: [
			{key: "tblrespnskey", opid: 3075, row: 0, value: "2", type: "number"},
			{key: "tblrespnskey", opid: 3076, row: 1, value: "1", type: "number"}, 
		],
		timestamp: 123456789,
		measured_concentration: 53.2,
		ups: [{id: 1, name: 'upname1'}, {id: 2, name: 'upname2'}]
	})

	it "is backwards compatible with the original hash" do expect(resp).to eq({
		table_inputs: [
			{key: "tblrespnskey", opid: 3075, row: 0, value: "2", type: "number"},
			{key: "tblrespnskey", opid: 3076, row: 1, value: "1", type: "number"},
		],
		timestamp: 123456789,
		measured_concentration: 53.2
		ups: [{id: 1, name: 'upname1'}, {id: 2, name: 'upname2'}]
	})
	end
	
	it "returns the value at the given key like a ruby hash with get_response" do
	    expect(resp.get_response(:badkey)).to eq(nil)
	    expect(resp.get_response(:measured_concentration)).to eq(53.2)
	end

	it "returns a response with the given var, whether passed a \
symbol, string, or integer" do
	    expect(resp.get_response("measured_concentration")).to eq(53.2)
	end
	
	it "hides table_inputs and timestamp from the client" do
		expect(resp.get_response(:table_inputs)).to eq(nil)
	    expect(resp.get_response(:timestamp)).to eq(nil)
	end

	it "returns a ruby hash representing the data with responses" do
    	expect(resp.responses()).to (
    	eq({measured_concentration: 53.2, tblrespnskey: [2, 1], ups: [Upload.find(1), Upload.find(2)]}) )
    end

    it "returns the timestamp of the showblock with timestamp()" do
		expect(resp.timestamp).to eq(123456789)
	end

	it "returns a sorted array corresponding to rows of the table with \
get_response when the given key is the name of an table response" do
		expect(resp.get_response(:tblrespnskey)).to eq([2, 1])
		expect(resp.get_response("tblrespnskey")).to eq([2, 1])
	end

	it "returns the contents of a specific input cell of table with \
get_table_response when parameterized with an op or row" do
		expect(resp.get_table_response(:tblrespnskey, op: 3075)).to eq(2)
		expect(resp.get_table_response(:tblrespnskey, op: 3076)).to eq(1)
		expect(resp.get_table_response(:tblrespnskey, row: 0)).to eq(2)
		expect(resp.get_table_response(:tblrespnskey, row: 1)).to eq(1)
	end

	it "raises an error if you misuse the interface for get_table_response \
(which requires exactly one optional argument)" do
		expect{resp.get_table_response(:measured_concentration)}.to (
		raise_error(TableCellUndefined) )

		expect{resp.get_table_response(:tblrespnskey)}.to (
		raise_error(TableCellUndefined) )

		expect{resp.get_table_response(:tblrespnskey, op: 3075, row: 0)}.to (
		raise_error(TableCellUndefined) )
	end

	it "Retrieves uploaded files as an array with get_upload_response" do
		expect(resp.get_upload_response(:ups)).to eq([Upload.find(1), Upload.find(2)])
	end

	it "Returns nil when get_upload_response is attempted on a key that is not an upload response" do
		expect(resp.get_upload_response(:measured_concentration)).to eq(nil)
	end

	it "works with large and complex response hashes" do
		bigresp = ShowResponse.new({
			table_inputs: [ 
				{key: "tblrespnskey", opid: 3075, row: 0, value: 2, type: "number"},
				{key: "tblrespnskey", opid: 3076, row: 1, value: 1, type: "number"},
				{key: "tblrespnskey", opid: 3077, row: 2, value: 3, type: "number"},
				{key: "tblrespnskey", opid: 3078, row: 3, value: 4, type: "number"},
				{key: "tblrespnskey", opid: 3080, row: 4, value: 5, type: "number"},
				{key: "tblrespnskey", opid: 3079, row: 5, value: 6, type: "number"},
				{key: "tblrespnskey2", opid: -4, row: 3, value: "four", type: "text"},
				{key: "tblrespnskey2", opid: -5, row: 4, value: "five", type: "text"},
				{key: "tblrespnskey2", opid: -6, row: 5, value: "six", type: "text"},
				{key: "tblrespnskey2", opid: -1, row: 0, value: "one", type: "text"},
				{key: "tblrespnskey2", opid: -2, row: 1, value: "two", type: "text"},
				{key: "tblrespnskey2", opid: -3, row: 2, value: "three", type: "text"},
			], 
			response1: "SUPERLONGSTRINGSUPERLONGSTRINGSUPERLONG\
STRINGSUPERLONGSTRINGSUPERLONGSTRING",
			response2: 1412312312312312312312412312312312,
			response3: "one more datum",
			timestamp: 1530914953.496
		})

		expect(bigresp.get_response(:table_inputs)).to eq(nil)

	    expect(bigresp.get_response(:timestamp)).to eq(nil)

	    expect(bigresp.get_response(:badkey)).to eq(nil)

	    expect(bigresp.get_response(:response1)).to (
	    eq("SUPERLONGSTRINGSUPERLONGSTRINGSUPERLONGSTRINGSUPERL\
ONGSTRINGSUPERLONGSTRING"))

		expect(bigresp.get_response(:response2)).to (
		eq(1412312312312312312312412312312312) )

		expect(bigresp.get_response(:response3)).to eq("one more datum")

		expect(bigresp.timestamp).to eq(1530914953.496)

		expect(bigresp.get_response(:tblrespnskey)).to eq([2,1,3,4,5,6])

		expect(bigresp.get_response(:tblrespnskey2)).to(
		eq(["one", "two", "three", "four", "five", "six"]) )

		expect(bigresp.get_response(:response2)).to (
		eq(1412312312312312312312412312312312) )

		expect(bigresp.get_response(:response3)).to eq("one more datum")

		expect(bigresp.get_table_response(:tblrespnskey,
					op: Operation.find(3079))).to eq(6)

		expect(bigresp.get_table_response(:tblrespnskey, op: 3079)).to eq(6)

		expect(bigresp.get_table_response(:tblrespnskey, row: 1)).to eq(1)

		expect(bigresp.get_table_response(:tblrespnskey2, row: 0)).to eq("one")

		expect{bigresp.get_table_response(:measured_concentration)}.to (
		raise_error(TableCellUndefined) )

		expect{bigresp.get_table_response(:tblrespnskey2, op: 3079)}.to (
		raise_error(TableCellUndefined) )

		expect{bigresp.get_table_response(:tblrespnskey, op: 3079, row: 5)}.to (
		raise_error(TableCellUndefined) )

		expect{bigresp.get_table_response(:tblrespnskey, op: 5000)}.to (
		raise_error(ActiveRecord::RecordNotFound) )

		expect{bigresp.get_table_response(:tblrespnskey, row: 100)}.to (
		raise_error(TableCellUndefined) )
	end	
end