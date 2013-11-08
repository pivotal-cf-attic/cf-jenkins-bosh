module ChefSpecHelper
  def stub_include_recipe_calls
    # see:
    # * https://gist.github.com/RoboticCheese/5505152/
    # * https://github.com/jwitrick/extended_drbd/blob/master/spec/spec_helper.rb
    Chef::Cookbook::Metadata.any_instance.stub(:depends) # ignore external cookbook dependencies

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    Chef::RunContext.any_instance.stub(:loaded_recipe?).and_return(false)
    Chef::Recipe.any_instance.stub(:include_recipe) do |i|
      Chef::RunContext.any_instance.stub(:loaded_recipe?).with(i).and_return(true)
      @included_recipes << i
    end
    Chef::RunContext.any_instance.stub(:loaded_recipes).and_return(@included_recipes)
  end
end
