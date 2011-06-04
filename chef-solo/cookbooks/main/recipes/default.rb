directory "/this/is/very/nested/directory" do
  owner "root"
  group "root"
  recursive true
end
file "/tmp/something" do
  owner "root"
  group "root"
  mode "0755"
  action :delete
end
