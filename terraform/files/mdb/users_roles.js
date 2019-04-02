db.createUser(
    {
      user: "MongoAdmin",
      pwd: "M0n60Adm1n",
      roles: [ { role: "userAdminAnyDatabase", db: "admin" }]
    }
  );

db = db.getSiblingDB('oneMillionDocDB');

db.createUser(
  {
    user: "DocsAdmin",
    pwd: "D0csAdm1n",
    roles: [ { role: "readWrite", db: "oneMillionDocDB" }]
  }
);
