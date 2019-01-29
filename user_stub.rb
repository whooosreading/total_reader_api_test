class UserStub
	attr_accessor :id, :grade_level, :total_reader_ref_id_suffix, :demo

	def initialize(id: nil, grade_level: nil)
		self.id = id || rand(10000000)
		self.grade_level = grade_level || rand(12)
	end
end