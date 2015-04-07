# -*- coding: utf-8 -*-
require 'test_helper'

class TestParanoid2 < Test::Unit::TestCase
  test 'has a version number' do
    assert Paranoid2::VERSION
  end

  sub_test_case "PlainModel" do
    setup do
      PlainModel.unscoped.delete_all
    end

    test 'is not paranoid' do
      assert_equal false, PlainModel.paranoid?
    end

    test 'has not paranoid object' do
      assert_equal false, PlainModel.new.paranoid?
    end

    test 'has default destroy behavior' do
      object = PlainModel.new

      assert_equal 0, PlainModel.count
      object.save!
      assert_equal 1, PlainModel.count

      object.destroy

      assert_equal Paranoid2.alive_value, object.deleted_at
      assert_equal true, object.frozen?

      assert_equal 0, PlainModel.count
      assert_equal 0, PlainModel.unscoped.count
    end
  end

  sub_test_case "ParanoidModel" do
    setup { ParanoidModel.unscoped.destroy_all! }

    test 'is paranoid' do
      assert ParanoidModel.paranoid?
    end

    test 'has paranoid object' do
      assert ParanoidModel.new.paranoid?
    end

    test 'returns valid value with to_param' do
      object = ParanoidModel.create!
      param = object.to_param

      object.destroy

      assert_equal param, object.to_param
    end

    test "it doesn't actually destroy object" do
      assert_equal 0, ParanoidModel.count
      object = ParanoidModel.create!
      assert_equal 1, ParanoidModel.count

      object.destroy

      assert_equal false, object.deleted_at.nil?
      assert_equal true, object.frozen?

      assert_equal 0, ParanoidModel.count
      assert_equal 1, ParanoidModel.unscoped.count
    end

    test 'has working only_deleted scope' do
      a = ParanoidModel.create!
      a.destroy
      b = ParanoidModel.create
      assert_equal [a], ParanoidModel.only_deleted
    end

    test 'can be force destroyed' do
      object = ParanoidModel.create!
      object.destroy(force: true)

      assert_equal true, object.destroyed?

      assert_equal 0, ParanoidModel.unscoped.count
    end

    test 'can be force deleted' do
      object = ParanoidModel.create!
      object.delete(force: true)

      assert_equal true, object.deleted?
      assert_equal 0, ParanoidModel.unscoped.count
    end

    test 'works with relation scopes' do
      parent1 = ParentModel.create!
      parent2 = ParentModel.create!
      a = ParanoidModel.create!(parent_model: parent1)
      b = ParanoidModel.create!(parent_model: parent2)
      a.destroy
      b.destroy
      assert_equal 0, parent1.paranoid_models.count
      assert_equal 1, parent1.paranoid_models.only_deleted.count

      c = ParanoidModel.create(parent_model: parent1)
      assert_equal 2, parent1.paranoid_models.with_deleted.count
      assert_equal [a, c], parent1.paranoid_models.with_deleted
    end

    test 'allows "Model#includes"' do
      parent1 = ParentModel.create!
      parent2 = ParentModel.create!
      a = ParanoidModel.create!(parent_model: parent1)
      b = ParanoidModel.create!(parent_model: parent2)

      l = ActiveRecord::Base.logger
      # ActiveRecord::Base.logger = Logger.new(STDOUT)
      res = ParanoidModel.includes(:parent_model).merge(ParentModel.with_deleted).references(:parent_model).to_a
      ActiveRecord::Base.logger = l
    end

    test 'works with has_many_through relationships' do
      employer = Employer.create!
      employee = Employee.create!

      assert_equal 0, employer.jobs.count
      assert_equal 0, employer.employees.count
      assert_equal 0, employee.jobs.count
      assert_equal 0, employee.employers.count

      job = Job.create employer: employer, employee: employee

      assert_equal 1, employer.jobs.count
      assert_equal 1, employer.employees.count
      assert_equal 1, employee.jobs.count
      assert_equal 1, employee.employers.count

      employee2 = Employee.create
      job2 = Job.create employer: employer, employee: employee2
      employee2.destroy

      assert_equal 2, employer.jobs.count
      assert_equal 1, employer.employees.count

      job.destroy

      assert_equal 1, employer.jobs.count
      assert_equal 0, employer.employees.count
      assert_equal 0, employee.jobs.count
      assert_equal 0, employee.employers.count
    end
  end

  sub_test_case "CallbackModel" do
    test 'delete without callback' do
      object = CallbackModel.create!
      object.delete

      assert_equal nil, object.callback_called
    end

    test 'destroy with callback' do
      object = CallbackModel.create!
      object.destroy

      assert_equal true, object.callback_called
    end
  end

  sub_test_case "FeaturefulModel" do
    setup do
      FeaturefulModel.unscoped.destroy_all!
    end

    test 'chains paranoid models' do
      scope = FeaturefulModel.where(name: 'foo').only_deleted
      assert_equal 'foo', scope.where_values_hash['name']
    end

    test 'validates uniqueness with scope' do
      a = FeaturefulModel.create!(name: 'yury', phone: '9106701550')
      b = FeaturefulModel.new(name: 'bla', phone: '9106701550')
      assert_equal false, b.valid?
      a.destroy
      assert_equal true, b.valid?
    end
  end
end
