# typed: strict
# frozen_string_literal: true

# By default, the open method returns a StringIO object when the file is smaller than a certain size,
# otherwise it returns a Tempfile object. To avoid this annoying behavior, we set the threshold to 0,
# to it always returns a Tempfile.

OpenURI::Buffer.const_set 'StringMax', 0
