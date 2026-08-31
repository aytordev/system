{
  description = "Non-sensitive secrets fixture for CI checks";

  outputs = _: {
    username = "aytordev";
    useremail = "ci@example.test";
    userfullname = "CI User";
    users = {
      aytordev = {
        username = "aytordev";
        useremail = "ci@example.test";
        userfullname = "CI User";
      };
      avicente = {
        username = "avicente";
        useremail = "avicente@example.test";
        userfullname = "Avicente User";
      };
    };
  };
}
