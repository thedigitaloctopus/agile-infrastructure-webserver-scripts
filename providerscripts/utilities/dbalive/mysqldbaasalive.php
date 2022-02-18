 <?php
$servername = $argv[1];
$username = $argv[2];
$password = $argv[3];
$dbname = $argv[4];
$serverport = (int) $argv[5];


$tmp_db=bin2hex(openssl_random_pseudo_bytes(4));

// Create connection
$conn = new mysqli($servername, $username, $password, "", $serverport);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


// Create database
$sql = "CREATE DATABASE ${tmp_db}";
if ($conn->query($sql) === TRUE) {
  echo "ALIVE";
}

$sql = "DROP DATABASE ${tmp_db}";

$conn->close();
?>
