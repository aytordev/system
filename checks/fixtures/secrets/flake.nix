{
  description = "Non-sensitive secrets fixture for CI checks";

  outputs = _: {
    username = "aytordev";
    useremail = "ci@example.test";
    userfullname = "CI User";
  };
}
