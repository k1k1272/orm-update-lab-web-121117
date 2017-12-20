require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students ;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    student = Student.new(row[1], row[2], row[0])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute('SELECT * FROM students ORDER BY id DESC LIMIT 1')[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1;
    SQL

    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first

  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ? ;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
