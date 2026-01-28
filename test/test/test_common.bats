bats_load_library 'bats-assert'
bats_load_library 'bats-support'


setup() {
	load 'stella_bats_helper.bash'
}

teardown() {
    true
}


# GENERIC -------------------------------------------------------------------
@test "build_jq_expr_from_path" {
	
	run build_jq_expr_from_path ".a.b.c"
	assert_output '.["a"]["b"]["c"]'

	run build_jq_expr_from_path "a.b.c"
	assert_output '.["a"]["b"]["c"]'

  run build_jq_expr_from_path a.0.b
  assert_output '.["a"][0]["b"]'

	run build_jq_expr_from_path .mcpServers.destkop-commander
	assert_output '.["mcpServers"]["destkop-commander"]'

  run build_jq_expr_from_path 'http\.proxy'
	assert_output '.["http.proxy"]'

  run build_jq_expr_from_path 'a.0.http\.proxy'
  assert_output '.["a"][0]["http.proxy"]'

}


@test "build_jq_array_from_path" {

	run build_jq_array_from_path ".a.b.c"
	assert_output '["a","b","c"]'

	run build_jq_array_from_path "a.b.c"
	assert_output '["a","b","c"]'

	run build_jq_array_from_path a-romeo.b.c
	assert_output '["a-romeo","b","c"]'

  run build_jq_array_from_path ".a.0.c"
	assert_output '["a",0,"c"]'

  run build_jq_array_from_path 'http\.proxy'
	assert_output '["http.proxy"]'

  run build_jq_array_from_path "http\.proxy"
	assert_output '["http.proxy"]'

  run build_jq_array_from_path 'a.http\.proxy'
	assert_output '["a","http.proxy"]'

  run build_jq_array_from_path 'a.http\Xproxy'
  # NOTE : in json \X is encoded as \\X
	assert_output '["a","http\\Xproxy"]'

  run build_jq_array_from_path 'a.http\\proxy'
	assert_output '["a","http\\proxy"]'

}


@test "json_has_path" {

	run bash -c '
		echo '{"a":{"b":{"c": "value","d":"value"}}}' | json_has_path ".a.b.c"
	'
	assert_success

	run json_has_path ".a.b.w" <<'EOF'
{
  "a": {
	"b": {
	  "c": "value"
	}
  }	
}
EOF
	assert_failure

}



@test "json_set_key1" {

	run json_set_key "a.b.c" '"new_value"'
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "c": "new_value"
    }
  }
}
EOF
	)
	assert_output "$expected"
}


@test "json_set_key2" {

	run json_set_key "a.b.c" '"new_value"' <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "c": "new_value",
      "d": "value"
    }
  }
}
EOF
	)
	assert_output "$expected"
}

@test "json_set_key3" {

	run json_set_key "users.admins" '["alice","bob"]' <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  },
  "users": {
    "admins": [
      "alice",
      "bob"
    ]
  }
}

EOF
	)
	assert_output "$expected"
}




@test "json_set_key4" {

	run json_set_key "a.b.array.3" '999' <<'EOF'
{"a":{"b":{"array":[10,20,30,40,50]}}}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "array": [
        10,
        20,
        30,
        999,
        50
      ]
    }
  }
}
EOF
	)
	assert_output "$expected"
}




@test "json_del_key1" {

	run json_del_key "a.b.c" <<'EOF'
{
  "a": {
    "b": {
      "c": "value"
    }
  }
}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {}
  }
}
EOF
	)
	assert_output "$expected"

}

@test "json_del_key2" {

	run json_del_key "a.b.c" <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "d": "value"
    }
  }
}
EOF
	)
	assert_output "$expected"

}

@test "json_del_key3" {

	run json_del_key "a.w" <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
	)
	assert_output "$expected"

}








@test "json_del_key_from_file1" {

	tmp="$(mktemp)"
	cat >"$tmp" <<'EOF'
{
  "a": {
    "b": {
      "c": "value"
    }
  }
}
EOF

	run json_del_key_from_file "a.b.c" "$tmp"
	assert_success
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {}
  }
}
EOF
	)
	assert_equal "$(cat "$tmp")" "$expected"

}


@test "json_del_key_from_file2" {

	tmp="$(mktemp)"
	cat >"$tmp" <<'EOF'
{ "a": { "b": { "c": "value", "d": "value" }}}
EOF

	run json_del_key_from_file "a.b.d" "$tmp"
 	assert_success
 	expected=$( cat <<'EOF'
{
  "a": {
    "b": {
      "c": "value"
    }
  }
}
EOF
 	)
 	assert_equal "$(cat "$tmp")" "$expected"

}

@test "json_del_key_from_file3" {

	tmp="$(mktemp)"
	cat >"$tmp" <<'EOF'
{ "a": { "b": { "c": "value", "d": "value" }}}
EOF

	run json_del_key_from_file "a.w.d" "$tmp"
 	assert_failure
 	expected=$( cat <<'EOF'
{
  "a": {
    "b": {
      "c": "value",
      "d": "value"
    }
  }
}
EOF
 	)
 	assert_equal "$(cat "$tmp")" "$expected"

	rm -f $tmp
}







@test "sanitize_json" {
	
	run sanitize_json '{ "to" :"a",}'
	expected=$(cat <<'EOF'
{
  "to": "a"
}
EOF
)
	assert_output "$expected"

	run sanitize_json '{ "to" :"a",}'
	assert_output "$expected"

}








@test "test_and_fix_json_file" {

	tmp="$(mktemp)"
  	cat >"$tmp" <<'EOF'
{ "to" :"a",}
EOF

	run test_and_fix_json_file "$tmp"
	assert_success

	rm -f $tmp
}











@test "merge_json_file1" {

	tmp1="$(mktemp)"
	tmp2="$(mktemp)"

  	cat >"$tmp1" <<'EOF'
{
  "a": {
	"b": "new_value1",
	"c": "value2"
  },
  "d": "value3"
}
EOF

  	cat >"$tmp2" <<'EOF'
{
  "a": {
	"b": "value1",
	"e": "value4"
  },
  "f": "value5"
}
EOF

	run merge_json_file "$tmp1" "$tmp2"
	assert_success

	expected=$(cat <<'EOF'
{
  "a": {
    "b": "new_value1",
    "e": "value4",
    "c": "value2"
  },
  "f": "value5",
  "d": "value3"
}
EOF
	)
	assert_equal "$(cat "$tmp2")" "$expected"

	rm -f $tmp1 $tmp2
}








@test "json_set_key_into_file1" {

	tmp="$(mktemp)"
	cat >"$tmp" <<'EOF'
{
  "a": {
    "b": {
      "c": "value"
    }
  }
}
EOF

	run json_set_key_into_file "a.b.c" '"test"' "$tmp"
	assert_success
	expected=$(cat <<'EOF'
{
  "a": {
    "b": {
      "c": "test"
    }
  }
}
EOF
	)
	assert_equal "$(cat "$tmp")" "$expected"

}








