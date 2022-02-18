 <?php
$servername = $argv[1];
$username = $argv[2];
$password = $argv[3];
$dbname = $argv[4];
$serverport = (int) $argv[5];

//Make sure the database exists which it might not if we are deploying from snapshots to a managed database

$conn = new mysqli($servername, $username, $password, "", $serverport);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database - this will usually error out but that's OK. 
$sql = "CREATE DATABASE ${dbname}";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $serverport);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "show tables";
$result = $conn->query($sql);

if ($result -> connect_errno) {
  echo "Failed to connect to MySQL: " . $result -> connect_error;
}
else
{
   echo "ALIVE";
}

$conn->close();
?>
