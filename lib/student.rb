require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end
end
