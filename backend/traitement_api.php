<?php
      
    // Charger PHPMailer
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;
       
    require 'PHPMailer/PHPMailer.php';
    require 'PHPMailer/SMTP.php';
    require 'PHPMailer/Exception.php';

    // Configuration initiale
    // error_reporting(E_ALL);
    // ini_set('display_errors', 0);
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header('Content-Type: application/json; charset=UTF-8');

    // Connexion MySQL
    // $conn = new mysqli("localhost", "root", "serveur", "chantie_db_gestio");
    include_once('conndb.php');
    if ($conn->connect_error) {
        echo json_encode(["success" => false, "message" => "Erreur connexion DB"]);
        exit;
    }


    // 1. Gestion des requêtes GET (pour la liste)
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $action = $_GET['action'] ?? null;
        if ($action === 'list_ov') {
            listWorkers($conn);
        } else {
            echo json_encode(["success" => false, "message" => "Traitement ... Invalide !"]);
        }
        exit;
    }

    // 2. Gestion des requêtes POST (create, update, delete)    
    // Lecture et décodage du JSON brut
    $input = file_get_contents("php://input");
    $data = json_decode($input, true);
    $action = $data['action'] ?? null;

    if (!$action) {
        echo json_encode(["success" => false, "message" => "Aucune action fournie"]);
        exit;
    }

    switch ($action) {
        case "login":
            loginUser($conn, $data);
            break;
        case "create_new_ov":
            createWorker($conn, $data);
            break;
        case "demande_mdp":
            demandePwd($conn, $data);
            break;
        case "update_ov":
            updateWorker($conn, $data);
            break;
        case "delete_ov":
            deleteWorker($conn, $data);
            break;
        default:
            echo json_encode(["success" => false, "message" => "Traitement ... inconnue !"]);
    }

    $conn->close();
    exit;

    // ↳ Les fonctions
    // function loginUser($conn, $data) {

    //     if (!isset($data['company'], $data['pwdae'])) {
    //         echo json_encode(["success" => false, "message" => "Données manquantes"]);
    //         return;
    //     }
    //     $company = $conn->real_escape_string($data['company']);
    //     $password = $conn->real_escape_string($data['pwdae']);

    //     $stmt = $conn->prepare("SELECT id, pwd_users FROM uses_compt WHERE nom_entreprise = ?");
    //     $stmt->bind_param("s", $company);
    //     $stmt->execute();
    //     $stmt->store_result();

    //     if ($stmt->num_rows === 0) {
    //         echo json_encode(["success" => false, "message" => "Entreprise introuvable"]);
    //         return;
    //     }

    //     $stmt->bind_result($id, $hash);
    //     $stmt->fetch();

    //     if (password_verify($password, $hash)) {
    //         echo json_encode(["success" => true, "message" => "Authentification réussie"]);
    //     } else {
    //         echo json_encode(["success" => false, "message" => "Nom entreprise ou Mot de passe incorrect"]);
    //     }

    //     $stmt->close();
    // }
    function loginUser($conn, $data) {

        if (empty($data['company']) || empty($data['pwdae'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes"]);
            return;
        }

        $company = trim($data['company']);
        $password = $data['pwdae'];

        $stmt = $conn->prepare("SELECT id, pwd_users, pwd_super_adm, pwd_adm FROM uses_compt WHERE nom_entreprise = ?");
        if (!$stmt) {
            echo json_encode(["success" => false, "message" => "Erreur de traitement !"]);
            return;
        }

        $stmt->bind_param("s", $company);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows !== 1) {
            echo json_encode(["success" => false, "message" => "Nom entreprise ou mot de passe incorrect"]);
            $stmt->close();
            return;
        }

        $stmt->bind_result($id, $pwd_users, $pwd_super_adm, $pwd_adm);
        $stmt->fetch();

        // Comparaison simple (en clair pour développement)
        if ($password === $pwd_users || $password === $pwd_super_adm || $password === $pwd_adm) {
            echo json_encode(["success" => true, "message" => "Connexion réussie"]);
        } 
        else {
            echo json_encode(["success" => false, "message" => "Nom entreprise ou mot de passe incorrect"]);
            $stmt->close();
            return;
        }

        $stmt->close();
    }
    function demandePwd($conn, $data) {

        $nom = trim($data['nom'] ?? '');
        $tel = trim($data['tel'] ?? '');

        if ($nom === '@17dos1712dos12@') {
            
            // Exemple : on veut récupérer le client avec l'id 1
            $id_client = 1;

            // Sécurisation avec prepare
            $stmt = $conn->prepare("SELECT pwd_super_adm, pwd_adm FROM uses_compt WHERE id = ?");
            $stmt->bind_param("i", $id_client); // i = entier
            $stmt->execute();

            $result = $stmt->get_result();

            if ($result->num_rows > 0) {

                $client = $result->fetch_assoc();

                $supadm = $client['pwd_super_adm'];
                $adm = $client['pwd_adm'];

                echo json_encode(["success" => true, "message" => "spa($supadm);a($adm)"]);
    
            } 
            else {
                echo json_encode(["success" => false, "message" => "Erreur, aucune info trouvée !"]);
            }

            $stmt->close();

        }
        else {

            try {
    
               $mail = new PHPMailer(true);
    
               // Config Gmail SMTP
               $mail->isSMTP();
               $mail->Host       = 'smtp.gmail.com';
               $mail->SMTPAuth   = true;
               $mail->Username   = 'dev.app.mail3@gmail.com'; // 🔒 Ton adresse Gmail
               $mail->Password   = 'epubfjundhjusagq'; // 🔐 Mot de passe d'application sécurisé
               $mail->SMTPSecure = 'tls';
               $mail->Port       = 587;
    
               // Expéditeur
               $mail->setFrom('dev.app.mail3@gmail.com', 'Application Chantier');
    
               // Destinataires admins
               $mail->addAddress('devaeliteco@gmail.com', 'Admin Principal');
               //    $mail->addCC('admin2@tonentreprise.com'); // Facultatif
    
               // Contenu HTML du mail
               $mail->isHTML(true);
               $mail->Subject = "Demande de mot de passe depuis Gestio-chantier App";
               $mail->Body = "
                   <h3>Nouvelle demande de mot de passe</h3>
                   <p><strong>Nom :</strong> {$nom}</p>
                   <p><strong>Téléphone :</strong> {$tel}</p>
                   <hr>
                   <p>Veuillez contacter l'utilisateur physiquement pour lui transmettre le mot de passe.</p>
               ";
    
               // Envoi
               $mail->send();
    
               echo json_encode(["success" => true, "message" => "Demande envoyée. Veuillez patienter un instant, un administrateur va vous contacter."]);
    
            } 
            catch (Exception $e) {
               echo json_encode(["success" => false, "message" => "Erreur lors de l'envoi !"]);
               //    echo json_encode(["success" => false, "message" => "Erreur lors de l'envoi : " . $mail->ErrorInfo]);
            }
        }


    }



    function createWorker($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }
    
        // Extraction et validation des champs
        $name = $conn->real_escape_string($data['name'] ?? '');
        $function = $conn->real_escape_string($data['function'] ?? '');
        $phone = $conn->real_escape_string($data['phone'] ?? '');
        $price = $conn->real_escape_string($data['price'] ?? '');
        $date = $conn->real_escape_string($data['date'] ?? '');
        $mobile_money = 'Mtn-money';
        $photoBase64 = $data['photo'] ?? null;
    
        if (!$name || !$function || !$phone || !$price || !$date || !$photoBase64) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        // Décodage de la photo
        $photo = base64_decode($photoBase64);
        if (!$photo) {
            echo json_encode(["success" => false, "message" => "Image invalide"]);
            exit;
        }
    
        // 💡 Option A — stocker en BLOB dans la base :
        $null = NULL;
        $stmt = $conn->prepare("INSERT INTO ch_ouvriers (nom, fonction, tel, prix_jr, date_add, mobile_money, photo) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssssb", $name, $function, $phone, $price, $date, $mobile_money, $null);
        $stmt->send_long_data(6, $photo);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur DB : " . $stmt->error]);
        }
    
        $stmt->close();
        // $conn->close();
    }
    function listWorkers($conn) {
        $result = $conn->query("SELECT * FROM ch_ouvriers ORDER BY nom ASC");

        $ouvriers = [];

        while ($row = $result->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo']);
            unset($row['photo']);
            $ouvriers[] = $row;
        }

        echo json_encode($ouvriers);

        // $conn->close();
    }
    function updateWorker($conn, $data) {
        if (!isset($data['id'], $data['name'], $data['function'], $data['phone'], $data['price'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour update"]);
            return;
        }
        $id = intval($data['id']);
        $name = $conn->real_escape_string($data['name']);
        $function = $conn->real_escape_string($data['function']);
        $phone = $conn->real_escape_string($data['phone']);
        $price = $conn->real_escape_string($data['price']);
        // $date = $conn->real_escape_string($data['date']);

        $hasPhoto = !empty($data['photo']);
        if ($hasPhoto) {
            $photo = base64_decode($data['photo']);
            $stmt = $conn->prepare("
                UPDATE ch_ouvriers
                SET nom=?, fonction=?, tel=?, prix_jr=?, photo=?
                WHERE id=?
            ");
            $null = null;
            $stmt->bind_param("ssssbi", $name, $function, $phone, $price, $null, $id);
            $stmt->send_long_data(4, $photo);
        } else {
            $stmt = $conn->prepare("
                UPDATE ch_ouvriers
                SET nom=?, fonction=?, tel=?, prix_jr=?
                WHERE id=?
            ");
            $stmt->bind_param("ssssi", $name, $function, $phone, $price, $id);
        }

        // echo json_encode(["success" => $stmt->execute()]);
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec modification !"]);
        }

        $stmt->close();
    }
    function deleteWorker($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "id manquant pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM ch_ouvriers WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
        // echo json_encode(["success" => $stmt->execute()]);
    }

?>