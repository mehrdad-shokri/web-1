=begin
require_relative 'app_services_test_base'
require 'json'

class GrouperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '443',
  'non-existant id raises exception' do
    id = kata_id
    error = assert_raises {
      grouper.manifest(id)
    }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'GrouperService', error.service_name
    assert_equal 'manifest', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ArgumentError', exception['class']
    assert_equal 'id:invalid', exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '444',
  'smoke test grouper.sha' do
    assert_sha grouper.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = make_manifest
    id = grouper.create(manifest)
    manifest['id'] = id
    assert_equal manifest, grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  the id can be completed
  and id?() is true
  and the manifest can be retrieved ) do
    id = grouper.create(make_manifest)
    assert grouper.id?(id)
    assert_equal id, grouper.id_completed(id[0..5])
    outer = id[0..1]
    inner = id[2..-1]
    id_completions = grouper.id_completions(outer)
    assert id_completions.include?(outer+inner)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'join/joined' do
    id = grouper.create(make_manifest)
    joined = grouper.joined(id)
    assert_equal({}, joined, 'someone has already joined!')
    (1..4).to_a.each do |n|
      index,sid = *grouper.join(id)
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert sid.is_a?(String), "#{n}: sid is a #{id.class.name}!"
      joined = grouper.joined(id)
      assert joined.is_a?(Hash), "#{n}: joined is a #{hash.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{sid}, #{index}, #{joined}"
      assert_equal sid, joined[index.to_s], diagnostic
    end
  end

  private

  def make_manifest
    manifest = starter.language_manifest('Java, JUnit', 'Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

end
=end

=begin
require_relative 'app_services_test_base'
require 'json'

class SinglerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '162'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '28C',
  'non-existent id raises exception' do
    id = kata_id
    error = assert_raises {
      singler.manifest(id)
    }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'SinglerService', error.service_name
    assert_equal 'manifest', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ArgumentError', exception['class']
    assert_equal 'id:invalid', exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '28D',
  'smoke test singler.sha' do
    assert_sha singler.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = make_manifest
    id = singler.create(manifest)
    manifest['id'] = id
    assert_equal manifest, singler.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  the id can be completed
  and id?() is true
  and the tags has tag0
  and the manifest can be retrieved ) do
    id = singler.create(make_manifest)
    assert singler.id?(id)
    assert_equal([tag0], singler.tags(id))
    assert_equal id, singler.id_completed(id[0..5])
    outer = id[0..1]
    inner = id[2..-1]
    id_completions = singler.id_completions(outer)
    assert id_completions.include?(outer+inner)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A20',
  'ran_tests() returns tags' do
    # This is an optimization to avoid web service
    # having to make a call back to storer to get the
    # tag numbers for the new traffic-light's diff handler.
    id = singler.create(make_manifest)

    tag1_files = starting_files
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    colour = 'amber'
    tags = singler.ran_tests(id, tag1_files, now, stdout, stderr, colour)

    expected = [
      tag0,
      { "colour"=>"amber", "time"=>[2016,12,5, 21,1,34] }
    ]
    assert_equal expected, tags

    now = [2016,12,5, 21,2,15]
    tags = singler.ran_tests(id, tag1_files, now, stdout, stderr, colour)
    expected = [
      tag0,
      { "colour"=>"amber", "time"=>[2016,12,5, 21,1,34] },
      { "colour"=>"amber", "time"=>[2016,12,5, 21,2,15] }
    ]
    assert_equal expected, tags
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A21',
  'after ran_tests()',
  'visible_files can be retrieved for any tag' do
    id = singler.create(make_manifest)
    tag0_files = starting_files

    assert_equal tag0_files, singler.visible_files(id)
    assert_equal tag0_files, singler.tag_visible_files(id,-1)

    tag1_files = starting_files
    tag1_files.delete('output')
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    colour = 'amber'
    singler.ran_tests(id,tag1_files, now, stdout, stderr, colour)
    tag1_files['output'] = stdout + stderr

    assert_equal tag1_files, singler.visible_files(id)
    assert_equal tag1_files, singler.tag_visible_files(id, -1)

    tag2_files = tag1_files.clone
    tag2_files.delete('output')
    tag2_files['readme.txt'] = 'Your task is to print...'
    now = [2016,12,6, 9,31,56]
    stdout = 'All tests passed'
    stderr = ''
    colour = 'green'
    singler.ran_tests(id, tag2_files, now, stdout, stderr, colour)
    tag2_files['output'] = stdout + stderr

    assert_equal tag2_files, singler.visible_files(id)
    assert_equal tag2_files, singler.tag_visible_files(id, -1)

    assert_equal tag0_files, singler.tag_visible_files(id,0)
    assert_equal tag1_files, singler.tag_visible_files(id, 1)
    assert_equal tag2_files, singler.tag_visible_files(id, 2)

    hash = singler.tags_visible_files(id, was_tag=0, now_tag=1)
    assert_equal tag0_files, hash['was_tag']
    assert_equal tag1_files, hash['now_tag']

    hash = singler.tags_visible_files(id, was_tag=1, now_tag=2)
    assert_equal tag1_files, hash['was_tag']
    assert_equal tag2_files, hash['now_tag']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'ran_tests() with very large file does not raise' do
    # This test fails if docker-compose.yml uses
    # [read_only:true] without also using
    # [tmpfs: /tmp]
    id = singler.create(make_manifest)

    files = starting_files
    files['very_large'] = 'X'*1024*500
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assertion failed'
    colour = 'amber'
    singler.ran_tests(id, files, now, stdout, stderr, colour)
  end

  private

  def make_manifest
    manifest = starter.language_manifest('Java, JUnit', 'Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

  def starting_files
    make_manifest['visible_files']
  end

end
=end
