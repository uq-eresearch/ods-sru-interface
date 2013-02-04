class University

  class << self

    def name
      ENV['UNIVERSITY_NAME'] || 'The University of Queensland'
    end

    def uri
      ENV['UNIVERSITY_URI'] || 'http://uq.edu.au/'
    end

  end

end