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

        if ($action === 'pwds') {
            getPwds($conn);
        } 
        else if ($action === 'list_projets') {
            listProjets($conn);
        }
        else if ($action === 'list_projetsAssign') {
            $idP = $_GET['idp'];
            listProjetsAssign($conn, $idP);
        }
        else if ($action === 'list_projetsAssignSup') {
            $idP = $_GET['idp'];
            listProjetsAssignSup($conn, $idP);
        }
        else if ($action === 'list_ov') {
            $id = $_GET['id'] ?? '';
            listWorkersProjet($conn, $id);
        } 
        else if ($action === 'list_ovProjetNonAssoc' || $action === 'list_ovProjetNonAssocLastQ') {
            $id = $_GET['id'] ?? '';
            $idQ = $_GET['idQ'] ?? '';
            listWorkersProjetNonAssoc($conn, $id, $idQ, $action);
        } 
        else if ($action === 'list_quinzaines') {
            $id = $_GET['id'] ?? '';
            listQuinzaines($conn, $id);
        }
        else if ($action === 'list_ovquinzaine') {
            $id = $_GET['id'] ?? '';
            listWorkersQuinzaine($conn, $id);
        }
        else if ($action === 'list_ovquinzainePaie') {
            $id = $_GET['id'] ?? '';
            listWorkersQuinzainePaie($conn, $id);
        }
        else if ($action === 'list_ovPointage') {
            $id = $_GET['id'] ?? '';
            $idp = $_GET['idp'] ?? '';
            $dateNow = $_GET['dateNow'] ?? '';
            listWorkersPointage($conn, $id, $idp, $dateNow);
        }
        else if ($action === 'histo_pointage_par_jour') {
            $idQ = intval($_GET['idQ']);
            histoPointage($conn, $idQ);
        }
        else if ($action === 'histo_paieOv') {
            $idQ = $_GET['idQ'];
            histoPaieOv($conn, $idQ);
        }
        else if ($action === 'list_straitantProjet') {
            $idP = $_GET['idP'];
            $typeOffre = $_GET['typeOffre'];
            listStraitantsProjet($conn, $idP, $typeOffre);
        }
        else if ($action === 'list_histo_rapportJr') {
            $idP = $_GET['idP'];
            listRapportJr($conn, $idP);
        }
        else if ($action === 'list_histo_livraisonMat') {
            $idP = $_GET['idP'];
            listLivraison($conn, $idP);
        }
        else if ($action === 'list_histo_sortieMat') {
            $idP = $_GET['idP'];
            listSortieMat($conn, $idP);
        }
        else if ($action === 'list_chefChantier') {
            listChefChantier($conn);
        }
        else {
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
        case "new_projet":
            createProjet($conn, $data);
            break;
        case "edit_projet":
            updateProjet($conn, $data);
            break;
        case "new_quinzaine":
            createQuinzaine($conn, $data);
            break;
        case "update_quinzaine":
            updateQuinzaine($conn, $data);
            break;
        case "create_new_ov_pageQ":
            createWorkerDepuisQuinz($conn, $data);
            break;
        case "assocOvQuinzaine":
            assocWorkerDepuisQuinz($conn, $data);
            break;
        case "pointage_worker":
            pointageOuvrier($conn, $data);
            break;
        case "paieEspecesOv":
            paieEspecesOv($conn, $data);
            break;
        case "sup_pointageOv":
            suppPointageOv($conn, $data);
            break;
        case "demande_mdp":
            demandePwd($conn, $data);
            break;
        case "update_ov":
            updateWorker($conn, $data);
            break;
        case "update_ovQuinzaine":
            updateWorkerQuinzaine($conn, $data);
            break;
        case "versementContrat":
            versementStraitantPrestataire($conn, $data);
            break;
        case "realisationContrat":
            progressionStraitantPrestataire($conn, $data);
            break;
        case "new_straitant":
            createStraitantPrestataire($conn, $data);
            break;
        case "edit_straitant":
            editeStraitantPrestataire($conn, $data);
            break;
        case "delete_straitant":
            deleteStraitantPrestataire($conn, $data);
            break;
        case "delete_ov":
            deleteWorker($conn, $data);
            break;
        case "delete_ovQ":
            deleteWorkerQuinzaine($conn, $data);
            break;
        case "add_rapport_jr":
            newRapportJr($conn, $data);
            break;
        case "add_livraison_mat":
            newLivraisonMat($conn, $data);
            break;
        case "add_sortie_mat":
            newSortieMat($conn, $data);
            break;
        case "edit_sortie_mat":
            editeSortieMat($conn, $data);
            break;
        case "delete_sortieMat":
            deleteSortieMat($conn, $data);
            break;
        case "edit_livraison_mat":
            editeLivraisonMat($conn, $data);
            break;
        case "edite_rapport_jr":
            editeRapportJr($conn, $data);
            break;
        case "delete_rapportJrlier":
            deleteRapportJr($conn, $data);
            break;
        case "delete_livraisonMat":
            deleteLivraison($conn, $data);
            break;
        case "updatePwdApp":
            updatePwdsApp($conn, $data);
            break;
        case "add_chef_chantier":
            newChefChantier($conn, $data);
            break;
        case "edit_chef_chantier":
            editeChefChantier($conn, $data);
            break;
        case "delete_chefCH":
            deleteChefChantier($conn, $data);
            break;
        case "assigner_projet":
            assignProjetChefToChantier($conn, $data);
            break;
        case "assigner_projetSup":
            SupAssignProjetChefToChantier($conn, $data);
            break;
        default:
            echo json_encode(["success" => false, "message" => "Traitement ... inconnue !"]);
    }

    $conn->close();
    exit;

    // ↳ Les fonctions utils
    function convertirEnFloatAvecVirgule($nombreAvecEspaces) {
        $nettoye = str_replace([" ", "\xc2\xa0"], "", $nombreAvecEspaces);
        $nettoye = str_replace(",", ".", $nettoye); // Convertit la virgule en point
        return floatval($nettoye);
    }
    function getPwds($conn) {
        $result = $conn->query("SELECT * FROM uses_compt WHERE id=1");

        $pwds = $result->fetch_assoc();
        echo json_encode($pwds);

        // $conn->close();
    }
    function updatePwdsApp($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $colonne_ = $data['colonne'];
        $newPwdApp = $data['newPwdApp'];
    
        if (!$colonne_ || !$newPwdApp) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE uses_compt SET $colonne_=? WHERE id=1 ");
        $stmt->bind_param("s", $newPwdApp);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();

    }

    // Gestion Login
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

    // Gestion Projet
    function createProjet($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }
    
        // Extraction et validation des champs
        // $name = $conn->real_escape_string($data['nom'] ?? '');
        // $client = $conn->real_escape_string($data['client'] ?? '');
        // $date_ = $conn->real_escape_string($data['date'] ?? '');
        // $ttal = $conn->real_escape_string($data['ttal'] ?? '');
        // $statut = $conn->real_escape_string($data['statut'] ?? '');

        $name = $data['nom'] ?? '';
        $bdg_mo = $data['bdgmo'] ?? '';
        $client = $data['client'] ?? '';
        $date_ = $data['date'] ?? '';
        $ttal = $data['ttal'] ?? '';
        $statut = $data['statut'] ?? '';
    
        if (!$name || !$client) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        // verification avec prepare
        $db_verify = $conn->prepare("SELECT nom_projet FROM tab_projet WHERE nom_projet = ?");
        $db_verify->bind_param("s", $name);
        $db_verify->execute();

        $result_v = $db_verify->get_result();
        if ($result_v->num_rows != 0) {
            echo json_encode(["success" => false, "message" => "Ce projet existe deja, créez un autre ou changez le nom du nouveau projet !"]);
            $db_verify->close();
            exit;
        }
    
        
        $stmt = $conn->prepare("INSERT INTO tab_projet (nom_projet, bdg_mo, client, date_create, ttal, statut) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssss", $name, $bdg_mo, $client, $date_, $ttal, $statut);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Projet enregistré !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
        $db_verify->close();
    }
    function listProjets($conn) {

        $result = $conn->query("SELECT * FROM tab_projet ORDER BY nom_projet ASC");
        $projets = [];
        while ($row = $result->fetch_assoc()) {
            $projets[] = $row;
        }
        echo json_encode($projets);
    }
    function listProjetsAssign($conn, $idp) {
        $projets = [];

        $query = "
            SELECT p.*
            FROM tab_projet p
            WHERE p.statut = 'En cours'
            AND p.id NOT IN (
                SELECT id_projet
                FROM tab_assign_projet_to_chef_ch
                WHERE id_chef_ch = ?
            )
            ORDER BY p.nom_projet ASC
        ";

        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $idp);
        $stmt->execute();

        $result = $stmt->get_result();
        while ($row = $result->fetch_assoc()) {
            $projets[] = $row;
        }

        echo json_encode($projets);
    }
    function listProjetsAssignSup($conn, $id) {

        $result = $conn->query("SELECT * FROM tab_assign_projet_to_chef_ch WHERE id_chef_ch = '$id' ORDER BY projet ASC");

        $straitants = [];
        while ($row = $result->fetch_assoc()) {
            $straitants[] = $row;
        }
        echo json_encode($straitants);
    }


    function updateProjet($conn, $data) {

        if (!isset($data['nom'], $data['client'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour update"]);
            return;
        }
        $id = intval($data['id']);
        // $name = $conn->real_escape_string($data['nom']);
        // $client = $conn->real_escape_string($data['client']);
        $name = $data['nom'] ?? '';
        $bdg_mo = $data['bdgmo'] ?? '';
        $client = $data['client'] ?? '';

        // verification avec prepare
        $db_verify = $conn->prepare("SELECT nom_projet FROM tab_projet WHERE nom_projet = ?");
        $db_verify->bind_param("s", $name);
        $db_verify->execute();

        $result_v = $db_verify->get_result();
        if ($result_v->num_rows > 1) {
            echo json_encode(["success" => false, "message" => "Ce projet existe deja, créez un autre ou changez le nom du nouveau projet !"]);
            $db_verify->close();
            exit;
        }
       
        $stmt = $conn->prepare("UPDATE tab_projet SET nom_projet=?, bdg_mo=?, client=? WHERE id=? ");
        $stmt->bind_param("sssi", $name, $bdg_mo, $client, $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec modification !"]);
        }

        $stmt->close();
        $db_verify->close();
    }

    // Gestion Quinzaine
    function createQuinzaine($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_projet = $data['idprojet'] ?? '';
        $periode = $data['session'] ?? '';
        $debut = $data['debut'] ?? '';
        $fin = $data['fin'] ?? '';
        $date_ = $data['date'] ?? '';
        // $statut = $data['statut'] ?? '';

        $sql_verifyQ = $conn->query("SELECT id, fin FROM tab_quinzaine WHERE id_projet = $id_projet ORDER BY id DESC LIMIT 1");
        $verifyDate = $sql_verifyQ->fetch_assoc();

        if ($sql_verifyQ->num_rows > 0) {

            // Convertir les dates envoyées en DateTime
            $nouvelleDebut = DateTime::createFromFormat('d-m-Y', $debut);

            // Récupère la date de fin de la dernière session
            $ancienFin   = DateTime::createFromFormat('d-m-Y', $verifyDate['fin']);

            $aujourdhui = new DateTime();

            // Différence entre aujourd'hui et la date de fin
            $diffJours = $aujourdhui->diff($ancienFin)->days;
            $estFuture = $ancienFin > $aujourdhui;

            // Vérifie si on est à 2 jours ou moins de la fin
            // if ($estFuture && $diffJours > 2) {
            if ($diffJours > 3) {
                echo json_encode([
                    "success" => false,
                    "message" => "Vous ne pouvez créer une nouvelle session que 3 jours avant la fin de la session actuelle.",
                ]);
                exit;
            }

            // Comparaison
            if ($nouvelleDebut < $ancienFin) {
                echo json_encode([
                    "success" => false, "message" => "La date de début de la nouvelle Session doit être postérieure ou égale à la date de fin du Session en cours !"]);
                exit;
            }
        }
    
        if (!$periode || !$debut || !$fin || !$date_ || !$id_projet) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        // verification avec prepare
        $db_verify = $conn->prepare("SELECT periode, debut, fin, id_projet FROM tab_quinzaine WHERE periode = ? AND debut = ? AND fin = ? AND id_projet = ? ");
        $db_verify->bind_param("ssss", $periode, $debut, $fin, $id_projet);
        $db_verify->execute();

        $result_v = $db_verify->get_result();
        if ($result_v->num_rows != 0) {
            echo json_encode(["success" => false, "message" => "Cette période a été deja créer !"]);
            $db_verify->close();
            exit;
        }
    
        
        $stmt = $conn->prepare("INSERT INTO tab_quinzaine (id_projet, periode, debut, fin, date_create) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss",$id_projet, $periode, $debut, $fin, $date_);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Session enregistrée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
        $db_verify->close();
    }
    function listQuinzaines($conn, $id) {

        $sql = $conn->query("SELECT * FROM tab_quinzaine WHERE id_projet = $id ORDER BY id DESC");
        $quinzaines = [];

        $nombre_total = $sql->num_rows;
        $q_run = $sql->num_rows;

        while ($row = $sql->fetch_assoc()) {

            // Nouvel élément, initialisation des valeurs
            $idQ = $row["id"];
            $mo = $conn->query("SELECT SUM(prix_jr * ttal_jr) AS ttalMo FROM tab_ov_quinzaine WHERE id_quinzaine = '$idQ' ");
            $moTTal = $mo->fetch_assoc();

            if ( $q_run == $nombre_total) {
                $quinzaines[] = [
                    "id" => $row["id"],
                    "id_projet" => $row["id_projet"],
                    "periode" => $row["periode"],
                    "debut" => $row["debut"],
                    "fin" => $row["fin"],
                    "date_create" => $row["date_create"],
                    "ttal" => strval($moTTal['ttalMo']),
                    "nber" => $nombre_total,
                    "qRun" => "oui"
                ];
            }
            else {
                $quinzaines[] = [
                    "id" => $row["id"],
                    "id_projet" => $row["id_projet"],
                    "periode" => $row["periode"],
                    "debut" => $row["debut"],
                    "fin" => $row["fin"],
                    "date_create" => $row["date_create"],
                    "ttal" => strval($moTTal['ttalMo']),
                    "nber" => $nombre_total,
                    "qRun" => "non"
                ];
            }

            $nombre_total -= 1;
            // $projets[] = $row;
        }
        echo json_encode($quinzaines);
    }
    function updateQuinzaine($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        // $id = $data['id'] ?? '';
        $id = intval($data['id']);
        $id_projet = $data['idprojet'] ?? '';
        $periode = $data['periode'] ?? '';
        $debut = $data['debut'] ?? '';
        $fin = $data['fin'] ?? '';

    
        if (!$periode || !$debut || !$fin) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        // verification avec prepare
        $db_verify = $conn->prepare("SELECT periode, debut, fin, id_projet FROM tab_quinzaine WHERE periode = ? AND debut = ? AND fin = ? AND id_projet = ? ");
        $db_verify->bind_param("ssss", $periode, $debut, $fin, $id_projet);
        $db_verify->execute();

        $result_v = $db_verify->get_result();
        if ($result_v->num_rows != 0) {
            echo json_encode(["success" => false, "message" => "Cette période a été deja créer !"]);
            $db_verify->close();
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE tab_quinzaine SET periode=?, debut=?, fin=? WHERE id=? AND id_projet=? ");
        $stmt->bind_param("sssis",$periode, $debut, $fin, $id, $id_projet);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Session modicifiée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur de modification !"]);
        }
    
        $stmt->close();
        $db_verify->close();
    }

    // Ouvrier 
    function listWorkersQuinzaine($conn, $id) {
        
        $sql = $conn->query("SELECT * FROM tab_ov_quinzaine WHERE id_quinzaine = $id ORDER BY nom ASC");
        $ouvriersQ = [];
        while ($row = $sql->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo']);
            unset($row['photo']);
            $ouvriersQ[] = $row;
        }
        echo json_encode($ouvriersQ);

    }
    function listWorkersQuinzainePaie($conn, $id) {
        
        $sql = $conn->query("SELECT * FROM tab_ov_quinzaine WHERE id_quinzaine = '$id' AND ttal_jr != '0' AND statut != 'Solder' ORDER BY nom ASC");
        $ouvriersQ = [];
        while ($row = $sql->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo']);
            unset($row['photo']);
            $ouvriersQ[] = $row;
        }
        echo json_encode($ouvriersQ);

    }
    function listWorkersPointage($conn, $id, $idp, $dateNow) {
    
        $sql = $conn->query("SELECT * FROM tab_ov_quinzaine WHERE id_quinzaine = '$id' AND id_projet = '$idp' AND jr_pointage != '$dateNow' ORDER BY nom ASC");
        $ouvriersPointage = [];
        while ($row = $sql->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo']);
            unset($row['photo']);
            $ouvriersPointage[] = $row;
        }
        echo json_encode($ouvriersPointage);

    }
    function pointageOuvrier($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['id_worker']);
        $getDiffDay = $data['getDiffDay'] ?? '';

        date_default_timezone_set('Africa/Abidjan');
        $dateHeurActuelle = date("d-m-Y");

        // reccupe ttalJr
        $sql_ttal_jr = $conn->query("SELECT id_projet, id_quinzaine, ttal_jr FROM tab_ov_quinzaine WHERE id = $id");
        $ttalJR = $sql_ttal_jr->fetch_assoc();

        $jr_ttal = intval($ttalJR['ttal_jr']) + 1;

        $idOv = $data['id_worker'];
        $dateN = date("Y-m-d");
        $idp_ = $ttalJR['id_projet'];
        $idq_ = $ttalJR['id_quinzaine'];
        $heureActuelle = date("H:i:s");

        $pointage_ov = $conn->prepare("INSERT INTO tab_histo_pointage_ouvrier (id_projet, id_quinzaine, id_ouvrier, date_pointage, heure) VALUES (?, ?, ?, ?, ?)");
        $pointage_ov->bind_param("sssss", $idp_, $idq_, $idOv, $dateN, $heureActuelle);
        $pointage_ov->execute();

        $colonn = "jr".$getDiffDay;
        $pointe_val = '1';
        $statut = "Non solder";

        $stmt = $conn->prepare("UPDATE tab_ov_quinzaine SET $colonn = ?, ttal_jr = ?, jr_pointage = ?, statut = ? WHERE id = ? ");
        $stmt->bind_param("ssssi",$pointe_val, $jr_ttal, $dateHeurActuelle, $statut, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Pointage effectué !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Une erreur est survenue, réessayer encore !"]);
        }
    
        $stmt->close();
        // $db_verify->close();
    }
    function histoPointage($conn, $idQ) {

                // -- DATE_FORMAT(p.date_pointage, '%d-%m-%Y') AS jour,
                // -- o.photo AS photo_base64
        $query = "SELECT 
                DATE_FORMAT(p.date_pointage, '%d-%m-%Y') AS jour,
                p.date_pointage AS jour,
                p.id AS idpointage,
                p.id_ouvrier AS idov,
                p.heure AS heureov,
                o.nom AS nom,
                o.fonction AS fonction,
                o.ttal_jr AS ttal_jrs,
                o.photo AS photo_base64p
            FROM tab_histo_pointage_ouvrier p
            INNER JOIN tab_ov_quinzaine o ON p.id_ouvrier = o.id
            WHERE p.id_quinzaine = ?
            ORDER BY p.date_pointage DESC, o.nom ASC ";

        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $idQ);
        $stmt->execute();
        $res = $stmt->get_result();

        $results = [];
        while ($row = $res->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo_base64p']);
            $row['ttal_jr'] = (intval($row['ttal_jrs']) - 1);
            $results[] = [
                "jour"     => $row["jour"],
                "id"     => $row["idpointage"],
                "idov"     => $row["idov"],
                "heure"     => $row["heureov"],
                "name"     => $row["nom"],
                "function" => $row["fonction"],
                "ttal_jr" => $row["ttal_jr"],
                "photo"    => $row["photo_base64"]
            ];
        }
        // echo json_encode($idQ);
        header('Content-Type: application/json');
        echo json_encode($results);
        exit;
    }
    function suppPointageOv($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $idPointage = intval($data['id']);
        $idOuvrier = intval($data['idov']);
        $getDiffDay = $data['getDiffDay'];
        $jr_ttal = $data['ttaljrs'];

        $stmt = $conn->prepare("DELETE FROM tab_histo_pointage_ouvrier WHERE id = ?");
        $stmt->bind_param("i", $idPointage);
        $stmt->execute();

        $colonn = "jr".$getDiffDay;
        $pointe_val = '0';
        $jr_pointage = '...';

        $stmtov = $conn->prepare("UPDATE tab_ov_quinzaine SET $colonn = ?, ttal_jr = ?, jr_pointage = ? WHERE id = ? ");
        $stmtov->bind_param("sssi",$pointe_val, $jr_ttal, $jr_pointage, $idOuvrier);
    
        // ✅ Exécution
        if ($stmtov->execute()) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false]);
        }

        $stmt->close();
        $stmtov->close();
        exit;
    }

    // Paie ouvriers
    function paieEspecesOv($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $idov = intval($data['idOv']);
        $idQ = intval($data['idQ']);
        $montantPaie = $data['montantPaie'];

        date_default_timezone_set('Africa/Abidjan');
        $dateHeurActuelle = date("d-m-Y, H:i:s");

        // reccupe ttalJr
        $sql_ttal_jr = $conn->query("SELECT id_projet, id_quinzaine, ttal_jr, prix_jr, paiement FROM tab_ov_quinzaine WHERE id = $idov");
        $ttalJR = $sql_ttal_jr->fetch_assoc();

        $newMontantPaie = round((convertirEnFloatAvecVirgule($ttalJR['paiement']) + convertirEnFloatAvecVirgule($montantPaie)), 3);

        $idp_ = $ttalJR['id_projet'];
        $idq_ = $ttalJR['id_quinzaine'];
        $idouvr = $data['idOv'];

        $ttalPaie = round((intval($ttalJR['ttal_jr']) * convertirEnFloatAvecVirgule($ttalJR['prix_jr'])), 3);

        $paie_ov_histo = $conn->prepare("INSERT INTO tab_histo_paie_ouvrier (id_projet, id_quinzaine, id_ouvrier, montant, date_heure) VALUES (?, ?, ?, ?, ?)");
        $paie_ov_histo->bind_param("sssss", $idp_, $idq_, $idouvr, $montantPaie, $dateHeurActuelle);
        $paie_ov_histo->execute();

        $statutPaie = 'Non solder';
        if ($ttalPaie == $newMontantPaie) {
            $statutPaie = 'Solder';
        }

        $stmt = $conn->prepare("UPDATE tab_ov_quinzaine SET paiement = ?, statut = ? WHERE id = ? ");
        $stmt->bind_param("ssi",$newMontantPaie, $statutPaie, $idov);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Paie effectué !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Une erreur est survenue, réessayer encore !"]);
        }
    
        $stmt->close();
        // $db_verify->close();
    }
    function histoPaieOv($conn, $idQ) {

        $query = "SELECT 
                p.id,
                p.montant,
                p.date_heure,
                o.nom,
                o.fonction,
                o.photo
            FROM tab_histo_paie_ouvrier p
            INNER JOIN tab_ov_quinzaine o ON p.id_ouvrier = o.id
            WHERE p.id_quinzaine = $idQ
            ORDER BY p.id DESC";

        $result = $conn->query($query);
        $ouvriers = [];

        while ($row = $result->fetch_assoc()) {
            $ouvriers[] = [
                "id"         => $row["id"],
                "montant"    => $row["montant"],
                "date_heure" => $row["date_heure"],
                "nomOv"      => $row["nom"],
                "fonction"   => $row["fonction"],
                "photo"      => base64_encode($row["photo"])
            ];
        }

        echo json_encode($ouvriers);
    }


    function createWorkerDepuisQuinz($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }
    
        // Extraction et validation des champs
        $idProjet = $data['idProjet'] ?? '';
        $idQuinzaine = $data['idQuinzaine'] ?? '';
        $qPeriode = $data['periode'] ?? '';
        $name = $data['name'] ?? '';
        $function = $data['function'] ?? '';
        $phone = $data['phone'] ?? '';
        $price = $data['price'] ?? '';
        $date = $data['date'] ?? '';
        $mobile_money = $data['mobileMoney'] ?? '';
        $photoBase64 = $data['photo'] ?? null;

        $sql_verifyQ = $conn->query("SELECT nom, fonction FROM ch_ouvriers WHERE id_projet = $idProjet");
        $verifyDate = $sql_verifyQ->fetch_assoc();

        if ($sql_verifyQ->num_rows > 0) {

            if ($verifyDate['nom'] == $name && $verifyDate['fonction'] == $function) {
                # code...
                echo json_encode([
                    "success" => false, "message" => "Cet ouvrier fait déjà partie de la liste du projet. Veuillez enregistrer un autre ouvrier !"]);
                exit;
            }
        }

        $sql_verifyQOV = $conn->query("SELECT nom, fonction FROM tab_ov_quinzaine WHERE id_projet = $idProjet AND id_quinzaine = $idQuinzaine");
        $verifOV = $sql_verifyQOV->fetch_assoc();

        if ($sql_verifyQOV->num_rows > 0) {

            if ($verifOV['nom'] == $name && $verifOV['fonction'] == $function) {
                echo json_encode([
                    "success" => false, "message" => "Cet ouvrier est déjà associé à cette session. Veuillez en enregistrer un autre !"]);
                exit;
            }
        }

    
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
        date_default_timezone_set('Africa/Abidjan');
        $dateHeurActuelle = date("d-m-Y, H:i:s");
        $val_jr = "0";
        $val_vide = "...";
        $paie = "0";
        $statut = "Non solder";

        $addOv_quinz = $conn->prepare("INSERT INTO tab_ov_quinzaine (id_projet, id_quinzaine, periode, nom, fonction, prix_jr, tel, mobile_money, 
        date_add, jr1, jr2, jr3, jr4, jr5, jr6, jr7, jr8, jr9, jr10, jr11, jr12, jr13, jr14, jr15, ttal_jr, jr_pointage, paiement, statut, photo) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $addOv_quinz->bind_param("ssssssssssssssssssssssssssssb",$idProjet, $idQuinzaine, $qPeriode, $name, $function,  $price, $phone, $mobile_money, $dateHeurActuelle, 
        $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr,
        $val_jr, $val_vide, $paie, $statut, $null);
        $addOv_quinz->send_long_data(28, $photo);

        
        // Exécution
        if ($addOv_quinz->execute()) {

            $sql_lastId_session = $conn->query("SELECT id FROM tab_ov_quinzaine ORDER BY id DESC LIMIT 1");
            $verif_id = $sql_lastId_session->fetch_assoc();

            $last_id = "1";
            if ($sql_lastId_session->num_rows > 0) {
                $last_id = strval($verif_id['id']);
            }
            
            $stmt = $conn->prepare("INSERT INTO ch_ouvriers (id_projet, id_ov, nom, fonction, tel, prix_jr, date_add, mobile_money, photo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssssb", $idProjet, $last_id, $name, $function, $phone, $price, $date, $mobile_money, $null);
            $stmt->send_long_data(8, $photo);
            
            // $addOv_quinz->execute();
            if ($stmt->execute()) {
                $stmt->close();
                echo json_encode(["success" => true, "message" => "Ouvrier enregistré avec succès !"]);
            }
            else {
                $stmt->close();
                echo json_encode(["success" => false, "message" => "Une erreur est survenue lors d'insertion, réssayez encore !"]);
            }

        } 
        else {
            echo json_encode(["success" => false, "message" => "Une erreur est survenue lors d'insertion !"]);
            // echo json_encode(["success" => false, "message" => "Erreur DB : " . $stmt->error]);
        }
    
        $addOv_quinz->close();
        // $conn->close();
    }
    function assocWorkerDepuisQuinz($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }
    
        // Extraction et validation des champs
        $idProjet = $data['idProjet'] ?? '';
        $idQuinzaine = $data['idQuinzaine'] ?? '';
        $qPeriode = $data['periode'] ?? '';
        $idov = intval($data['idov']);
        $name = $data['name'] ?? '';
        $function = $data['function'] ?? '';
        $phone = $data['phone'] ?? '';
        $price = $data['price'] ?? '';
        $date = $data['date'] ?? '';
        $mobile_money = $data['mobileMoney'] ?? '';
        $photoBase64 = $data['photo'] ?? null;
    
        // Décodage de la photo
        $photo = base64_decode($photoBase64);
        if (!$photo) {
            echo json_encode(["success" => false, "message" => "Image invalide"]);
            exit;
        }
    
        // 💡 Option A — stocker en BLOB dans la base :
        $null = NULL;
        date_default_timezone_set('Africa/Abidjan');
        $dateHeurActuelle = date("d-m-Y, H:i:s");
        $val_jr = "0";
        $val_vide = "...";
        $paie = "0";
        $statut = "Non solder";

        $addOv_quinz = $conn->prepare("INSERT INTO tab_ov_quinzaine (id_projet, id_quinzaine, periode, nom, fonction, prix_jr, tel, mobile_money, 
        date_add, jr1, jr2, jr3, jr4, jr5, jr6, jr7, jr8, jr9, jr10, jr11, jr12, jr13, jr14, jr15, ttal_jr, jr_pointage, paiement, statut, photo) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $addOv_quinz->bind_param("ssssssssssssssssssssssssssssb",$idProjet, $idQuinzaine, $qPeriode, $name, $function,  $price, $phone, $mobile_money, $dateHeurActuelle, 
        $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr, $val_jr,
        $val_jr, $val_vide, $paie, $statut, $null);
        $addOv_quinz->send_long_data(28, $photo);

        // Exécution
        if ($addOv_quinz->execute()) {
            echo json_encode(["success" => true]);
        } 
        else {
            echo json_encode(["success" => false]);
        }
    
        $addOv_quinz->close();
        // $conn->close();
    }
    function listWorkersProjet($conn, $id) {

        $result = $conn->query("SELECT * FROM ch_ouvriers WHERE id_projet = '$id' ORDER BY nom ASC");

        $ouvriers = [];

        while ($row = $result->fetch_assoc()) {
            $row['photo_base64'] = base64_encode($row['photo']);
            unset($row['photo']);
            $ouvriers[] = $row;
        }

        echo json_encode($ouvriers);

        // $conn->close();
    }
    function listWorkersProjetNonAssoc($conn, $id, $idQ, $action) {

        $ouvriers = [];

        if ($action === 'list_ovProjetNonAssoc') {
            # code...
            $nomFonctions = [];
            // 1. Récupérer les noms et fonctions des ouvriers associés à la quinzaine
            $sql = $conn->query("SELECT nom, fonction FROM tab_ov_quinzaine WHERE id_projet = '$id' AND id_quinzaine = '$idQ'");
    
            while ($row = $sql->fetch_assoc()) {
                $nom = $conn->real_escape_string($row['nom']);
                $fonction = $conn->real_escape_string($row['fonction']);
                $nomFonctions[] = "(`nom` = '$nom' AND `fonction` = '$fonction')";
            }
    
            // 2. Construire la requête si on a des ouvriers à exclure
            if (!empty($nomFonctions)) {
                $conditions = implode(' OR ', $nomFonctions);
                $query = "SELECT * FROM ch_ouvriers WHERE id_projet = $id AND NOT ($conditions) ORDER BY nom ASC";
            } else {
                // Aucun ouvrier dans la quinzaine => retourner tous les ouvriers du projet
                $query = "SELECT * FROM ch_ouvriers WHERE id_projet = $id ORDER BY nom ASC";
            }
    
            $result = $conn->query($query);
    
            while ($row = $result->fetch_assoc()) {
                $row['photo_base64'] = base64_encode($row['photo']);
                unset($row['photo']);
                $ouvriers[] = $row;
            }
        }
        elseif ($action === 'list_ovProjetNonAssocLastQ') {

            # code...
            $nomFonctions = [];
            $avantDernierId = '0';

            // $sqlastId = $conn->query("SELECT id FROM tab_quinzaine WHERE id_projet = '$id' ORDER BY id DESC LIMIT 1 OFFSET 1");
            $sqlastId = $conn->query("SELECT id FROM tab_quinzaine WHERE id_projet = '$id' AND id < '$idQ' ORDER BY id DESC LIMIT 1");

            if ($row = $sqlastId->fetch_assoc()) {
                $avantDernierId = $row['id'];
            }

            // 2. Récupérer tous les ouvriers de la quinzaine précédente
            $sqlPrec = $conn->query("SELECT * FROM tab_ov_quinzaine WHERE id_projet = '$id' AND id_quinzaine = '$avantDernierId' ORDER BY nom ASC");
            $ouvriersPrec = [];
            while ($row = $sqlPrec->fetch_assoc()) {
                $cle = $row['nom'] . '|' . $row['fonction'];
                $ouvriersPrec[$cle] = $row;
            }

            // 3. Récupérer tous les ouvriers de la quinzaine actuelle
            $sqlActu = $conn->query("SELECT nom, fonction FROM tab_ov_quinzaine WHERE id_projet = '$id' AND id_quinzaine = '$idQ'");
            $ouvriersActu = [];
            while ($row = $sqlActu->fetch_assoc()) {
                $cle = $row['nom'] . '|' . $row['fonction'];
                $ouvriersActu[] = $cle;
            }

            // 4. Ne garder que ceux de la quinzaine précédente qui ne sont pas dans la quinzaine actuelle
            foreach ($ouvriersPrec as $cle => $ouvrier) {
                if (!in_array($cle, $ouvriersActu)) {
                    $ouvrier['photo_base64'] = base64_encode($ouvrier['photo']);
                    unset($ouvrier['photo']);
                    $ouvriers[] = $ouvrier;
                }
            }

        }

        echo json_encode($ouvriers);
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
    function updateWorkerQuinzaine($conn, $data) {

        if (!isset($data['id'], $data['nom'], $data['fonction'], $data['phone'], $data['price'], $data['mobileMoney'], $data['photo'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour update"]);
            return;
        }
        $id = intval($data['id']);
        $name = $data['nom'];
        $function = $data['fonction'];
        $phone = $data['phone'];
        $price = $data['price'];
        $paie_mobile = $data['mobileMoney'];
        $photo = base64_decode($data['photo']);

        $stmt = $conn->prepare("UPDATE tab_ov_quinzaine SET nom=?, fonction=?, tel=?, prix_jr=?, mobile_money=?, photo=? WHERE id=? ");
        $null = null;
        $stmt->bind_param("sssssbi", $name, $function, $phone, $price, $paie_mobile, $null, $id);
        $stmt->send_long_data(5, $photo);

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
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
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
    function deleteWorkerQuinzaine($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM tab_ov_quinzaine WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
        // echo json_encode(["success" => $stmt->execute()]);
    }

    // Sous-traitant / Prestataire tab_straitant
    function createStraitantPrestataire($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $type_offre = $data['type_offre'] ?? '';
        $id_projet = $data['id_projet'] ?? '';
        $offre = $data['offre'] ?? '';
        $ouvrier = $data['ouvrier'] ?? '';
        $fonction = $data['fonction'] ?? '';
        $tel_ov = $data['tel_ov'] ?? '';
        $prix_offre = $data['prix_offre'] ?? '';
        $versement = $data['versement'] ?? '';
        $avances = $data['avances'] ?? '';
        $date_ = $data['date_'] ?? '';
        $delai_contrat = $data['delai_contrat'] ?? '';
        $statut = $data['statut'] ?? '';
        $realisation = '0';
    
        if (!$offre || !$ouvrier) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_straitant (id_projet, offre, ouvrier, fonction, tel_ov, prix_offre, versement, avances, date_add, delai_contrat, realisation, statut, type_offre) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssssssssss", $id_projet, $offre, $ouvrier, $fonction, $tel_ov, $prix_offre, $versement, $avances, $date_, $delai_contrat, $realisation, $statut, $type_offre);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Enregistrement effectué !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function versementStraitantPrestataire($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['idC']);
        $montant = $data['montantVerser'];
        $statut = $data['statut'];
    
        if (!$id || !$montant) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        $sql_ttal_versement = $conn->query("SELECT versement FROM tab_straitant WHERE id = '$id'");
        $ttalversement = $sql_ttal_versement->fetch_assoc();

        $ttalV = intval($ttalversement['versement']) + intval($montant);

        $stmt = $conn->prepare("UPDATE tab_straitant SET versement=?, statut=? WHERE id=? ");
        $stmt->bind_param("ssi", $ttalV, $statut, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Versement effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Une erreur est survenue, réessayez encore"]);
        }
    
        $stmt->close();
    }
    function progressionStraitantPrestataire($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['idC']);
        $realiser = $data['realisation'];
    
        if (!$id || !$realiser) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        $stmt = $conn->prepare("UPDATE tab_straitant SET realisation=? WHERE id=? ");
        $stmt->bind_param("si", $realiser, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Action effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Une erreur est survenue, réessayez encore"]);
        }
    
        $stmt->close();
    }
    function editeStraitantPrestataire($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['id']);
        $offre = $data['offre'] ?? '';
        $ouvrier = $data['ouvrier'] ?? '';
        $fonction = $data['fonction'] ?? '';
        $tel_ov = $data['tel_ov'] ?? '';
        $prix_offre = $data['prix_offre'] ?? '';
        $avances = $data['avancesC'] ?? '';
        $delai_contrat = $data['delai_contrat'] ?? '';
        $statut = $data['statut'] ?? '';
    
        if (!$offre || !$ouvrier) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }

        $stmt = $conn->prepare("UPDATE tab_straitant SET  offre=?, ouvrier=?, fonction=?, tel_ov=?, prix_offre=?, avances=?, delai_contrat=?, statut=? WHERE id=? ");
        $stmt->bind_param("ssssssssi", $offre, $ouvrier, $fonction, $tel_ov, $prix_offre, $avances, $delai_contrat, $statut, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur de modification, réessayez encore"]);
        }
    
        $stmt->close();
    }
    function deleteStraitantPrestataire($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM tab_straitant WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }
        $stmt->close();
    }
    function listStraitantsProjet($conn, $id, $typeOffre) {

        $result = $conn->query("SELECT * FROM tab_straitant WHERE id_projet = '$id' AND type_offre = '$typeOffre' ORDER BY id DESC");

        $straitants = [];
        while ($row = $result->fetch_assoc()) {
            $straitants[] = $row;
        }
        echo json_encode($straitants);

        // $conn->close();
    }

    // Rapport journalier
    function newRapportJr($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_projet = $data['id_projet'] ?? '';
        $rapportJr = $data['rapportJr'] ?? '';
        $incident = $data['incident'] ?? '';
        $visite_perso = $data['visite_perso'] ?? '';
        $essai_operation = $data['essai_operation'] ?? '';
        $doc_recus = $data['doc_recus'] ?? '';
        $reception_ov = $data['reception_ov'] ?? '';
        $info_hse = $data['info_hse'] ?? '';
        $appros_mat = $data['appros_mat'] ?? '';
        $mat_use = $data['mat_use'] ?? '';
        $perso_employer = $data['perso_employer'] ?? '';
        $travo_evolution = $data['travo_evolution'] ?? '';
        $travo_pourcntage = $data['travo_pourcntage'] ?? '';
        $mat_en_stocks = $data['mat_en_stocks'] ?? '';
        $observation_fin_jr = $data['observation_fin_jr'] ?? '';
        $climat = $data['climat'] ?? '';
        $date_ = $data['date_'] ?? '';
    
        if (!$rapportJr || !$incident) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_rapport_jr (id_projet, rapport_jr, incident, visite_perso, essai_operation, doc_recus, reception_ov, info_hse, 
        appros_mat, mat_use, perso_employer, travo_evolution, travo_pourcntage, date_, climat, mat_en_stocks, observation_fin_jr) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssssssssssssss", $id_projet, $rapportJr, $incident, $visite_perso, $essai_operation, $doc_recus, $reception_ov, $info_hse, 
        $appros_mat, $mat_use, $perso_employer, $travo_evolution, $travo_pourcntage, $date_, $climat, $mat_en_stocks, $observation_fin_jr);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Rapport enregistré !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function editeRapportJr($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_rapport = intval($data['id']);
        $rapportJr = $data['rapportJr'] ?? '';
        $incident = $data['incident'] ?? '';
        $visite_perso = $data['visite_perso'] ?? '';
        $essai_operation = $data['essai_operation'] ?? '';
        $doc_recus = $data['doc_recus'] ?? '';
        $reception_ov = $data['reception_ov'] ?? '';
        $info_hse = $data['info_hse'] ?? '';
        $appros_mat = $data['appros_mat'] ?? '';
        $mat_use = $data['mat_use'] ?? '';
        $perso_employer = $data['perso_employer'] ?? '';
        $travo_evolution = $data['travo_evolution'] ?? '';
        $travo_pourcntage = $data['travo_pourcntage'] ?? '';
        $mat_en_stocks = $data['mat_en_stocks'] ?? '';
        $observation_fin_jr = $data['observation_fin_jr'] ?? '';
        $climat = $data['climat'] ?? '';
        // $date_ = $data['date_'] ?? '';
    
        if (!$rapportJr || !$incident) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE tab_rapport_jr SET rapport_jr=?, incident=?, visite_perso=?, essai_operation=?, doc_recus=?, reception_ov=?, info_hse=?, 
        appros_mat=?, mat_use=?, perso_employer=?, travo_evolution=?, travo_pourcntage=?, climat=?, mat_en_stocks=?, observation_fin_jr=? 
        WHERE id=? ");
        $stmt->bind_param("sssssssssssssssi", $rapportJr, $incident, $visite_perso, $essai_operation, $doc_recus, $reception_ov, $info_hse, 
        $appros_mat, $mat_use, $perso_employer, $travo_evolution, $travo_pourcntage, $climat, $mat_en_stocks, $observation_fin_jr, $id_rapport);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Rapport modifié !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur lors de la modification, réessayez encore"]);
        }
    
        $stmt->close();
    }
    function listRapportJr($conn, $id) {

        $result = $conn->query("SELECT * FROM tab_rapport_jr WHERE id_projet = '$id' ORDER BY id DESC");

        $straitants = [];
        while ($row = $result->fetch_assoc()) {
            $straitants[] = $row;
        }
        echo json_encode($straitants);

        // $conn->close();
    }
    function deleteRapportJr($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM tab_rapport_jr WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
        // echo json_encode(["success" => $stmt->execute()]);
    }

    // Livraison matériaux
    function newLivraisonMat($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_projet = $data['id_projet'] ?? '';
        $design = $data['design'] ?? '';
        $unite = $data['unite'] ?? '';
        $qte = $data['qte'] ?? '';
        $nber_bl = $data['nber_bl'] ?? '';
        $qualites = $data['qualites'] ?? '';
        $retour_mat = $data['retour_mat'] ?? '';
        $qte_retour_mat = $data['qte_retour_mat'] ?? '';

        date_default_timezone_set('Africa/Abidjan');
        $date_ = date("d-m-Y, H:i:s");
    
        if (!$design || !$unite) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_histo_livraison_mat (id_projet, design, unite, qte, nber_bl, qualites, retour_mat, qte_retour_mat, date_) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssssss", $id_projet, $design, $unite, $qte, $nber_bl, $qualites, $retour_mat, $qte_retour_mat, $date_);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "L'information a été enregistrée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function editeLivraisonMat($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['id']);
        $design = $data['design'] ?? '';
        $unite = $data['unite'] ?? '';
        $qte = $data['qte'] ?? '';
        $nber_bl = $data['nber_bl'] ?? '';
        $qualites = $data['qualites'] ?? '';
        $retour_mat = $data['retour_mat'] ?? '';
        $qte_retour_mat = $data['qte_retour_mat'] ?? '';
    
        if (!$design || !$unite) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE tab_histo_livraison_mat SET design=?, unite=?, qte=?, nber_bl=?, qualites=?, retour_mat=?, qte_retour_mat=? WHERE id=? ");
        $stmt->bind_param("sssssssi", $design, $unite, $qte, $nber_bl, $qualites, $retour_mat, $qte_retour_mat, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function listLivraison($conn, $id) {

        $result = $conn->query("SELECT * FROM tab_histo_livraison_mat WHERE id_projet = '$id' ORDER BY id DESC");

        $straitants = [];
        while ($row = $result->fetch_assoc()) {
            $straitants[] = $row;
        }
        echo json_encode($straitants);

        // $conn->close();
    }
    function deleteLivraison($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM tab_histo_livraison_mat WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
        // echo json_encode(["success" => $stmt->execute()]);
    }

    // Sortie matériaux
    function newSortieMat($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_projet = $data['id_projet'] ?? '';
        $design = $data['design'] ?? '';
        $qte = $data['qte'] ?? '';
        $lieu = $data['lieu'] ?? '';

        date_default_timezone_set('Africa/Abidjan');
        $date_ = date("d-m-Y, H:i:s");
    
        if (!$design || !$qte) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_sortie_mat (id_projet, design, qte, lieu, date_) 
        VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $id_projet, $design, $qte, $lieu, $date_);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "L'information a été enregistrée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function editeSortieMat($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['id']);
        $design = $data['design'] ?? '';
        $qte = $data['qte'] ?? '';
        $lieu = $data['lieu'] ?? '';
    
        if (!$design || !$qte) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE tab_sortie_mat SET design=?, qte=?, lieu=? WHERE id=? ");
        $stmt->bind_param("sssi", $design, $qte, $lieu, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function listSortieMat($conn, $id) {

        $result = $conn->query("SELECT * FROM tab_sortie_mat WHERE id_projet = '$id' ORDER BY id DESC");

        $straitants = [];
        while ($row = $result->fetch_assoc()) {
            $straitants[] = $row;
        }
        echo json_encode($straitants);

        // $conn->close();
    }
    function deleteSortieMat($conn, $data) {
        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }
        $id = intval($data['id']);
        $stmt = $conn->prepare("DELETE FROM tab_sortie_mat WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
        // echo json_encode(["success" => $stmt->execute()]);
    }

    // Chef chantier
    function editeChefChantier($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id = intval($data['id']);
        $nom = $data['nom'] ?? '';
        $tel = $data['tel'] ?? '';
        $pwd = $data['pwd'] ?? '';
    
        if (!$nom || !$pwd) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("UPDATE tab_chef_chantier SET nom=?, tel=?, pwd=? WHERE id=? ");
        $stmt->bind_param("sssi", $nom, $tel, $pwd, $id);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Modification effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function newChefChantier($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $nom = $data['nom'] ?? '';
        $tel = $data['tel'] ?? '';
        $pwd = $data['pwd'] ?? '';
        $chantier = '';
    
        if (!$nom || !$pwd) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_chef_chantier (nom, tel, pwd, chantier) 
        VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $nom, $tel, $pwd, $chantier);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Enregistrement effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function listChefChantier($conn) {
        $chefs = [];

        $sql = "SELECT c.id AS id_chef, c.nom AS nom_chef, c.tel AS nber, c.pwd AS mdp, ap.projet
            FROM tab_chef_chantier c
            LEFT JOIN tab_assign_projet_to_chef_ch ap ON c.id = ap.id_chef_ch
            ORDER BY c.nom ASC, ap.projet ASC
        ";

        $result = $conn->query($sql);

        while ($row = $result->fetch_assoc()) {
            $id_chef = $row['id_chef'];

            if (!isset($chefs[$id_chef])) {
                $chefs[$id_chef] = [
                    "id" => $id_chef,
                    "nom" => $row['nom_chef'],
                    "tel" => $row['nber'],
                    "pwd" => $row['mdp'],
                    "projets" => []
                ];
            }

            if (!empty($row['projet'])) {
                $chefs[$id_chef]["projets"][] = $row['projet'];
            }
        }

        // Réindexation pour un tableau propre
        $chefs = array_values($chefs);

        echo json_encode($chefs);
    }

    function deleteChefChantier($conn, $data) {

        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }

        $id_ = $data['id'];
        $id = intval($data['id']);

        $stmt_ = $conn->prepare("DELETE FROM tab_assign_projet_to_chef_ch WHERE id_chef_ch=?");
        $stmt_->bind_param("s", $id_);
        $stmt_->execute();

        $stmt = $conn->prepare("DELETE FROM tab_chef_chantier WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt_->close();
        $stmt->close();
    }

    // Assignation projet to chef chantier
    function assignProjetChefToChantier($conn, $data) {

        if (!$data) {
            echo json_encode(["success" => false, "message" => "JSON invalide ou vide"]);
            exit;
        }

        $id_projet = $data['idp'] ?? '';
        $id_chef_ch = $data['idChef'] ?? '';
        $projet = $data['projet'] ?? '';
    
        if (!$id_projet || !$id_chef_ch) {
            echo json_encode(["success" => false, "message" => "Champs requis manquants"]);
            exit;
        }
    
        $stmt = $conn->prepare("INSERT INTO tab_assign_projet_to_chef_ch (id_projet, id_chef_ch, projet) 
        VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $id_projet, $id_chef_ch, $projet);
    
        // ✅ Exécution
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Enregistrement effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur d'enregistrement"]);
        }
    
        $stmt->close();
    }
    function SupAssignProjetChefToChantier($conn, $data) {

        if (!isset($data['id'])) {
            echo json_encode(["success" => false, "message" => "Données manquantes pour delete"]);
            return;
        }

        $id = intval($data['id']);

        $stmt = $conn->prepare("DELETE FROM tab_assign_projet_to_chef_ch WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Suppression effectuée !"]);
        } else {
            echo json_encode(["success" => false, "message" => "Échec suppression !"]);
        }

        $stmt->close();
    }


?>