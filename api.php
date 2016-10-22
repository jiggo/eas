<?php

CONST STANDARD = 0;
CONST MISTERY = 1;
CONST PASSIVE = 2;
CONST CHASE = 3;

$target_dir = "uploads/";
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
$imageFileType = pathinfo($target_file,PATHINFO_EXTENSION);
$dbconn = pg_connect("host=localhost dbname=combo2 user=combo password=combo") or die('connection failed');

// Check if image file is a actual image or fake image
if(isset($_REQUEST["calculate"])) { 
	
	$ids = array(
			460, //Crimson Fist
			//269, //UKON SAKON
			445, //Kakashi
			353, //Sakura
			434, //Sasuke
			461, //Chameleon
	);
	$i = 0;
	$highest_combo = 1;
	ninjasLoop($ids, $dbconn, $i, $highest_combo);
	
	echo "<pre>";
	echo "HIGHEST COMBO: ".$highest_combo;
	echo "</pre>";
	
	
	
	


} else if(isset($_POST["submit"])) {
	// Check if file already exists
	if (file_exists($target_file)) {
		echo "Sorry, file already exists.";
		$uploadOk = 0;
	}
	// Check file size
	if ($_FILES["fileToUpload"]["size"] > 5000000) {
		echo "Sorry, your file is too large.";
		$uploadOk = 0;
	}

	// Check if $uploadOk is set to 0 by an error
	if ($uploadOk == 0) {
		echo "Sorry, your file was not uploaded.";
		// if everything is ok, try to upload file
	} else {
		if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
			echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";
		} else {
			echo "Sorry, there was an error uploading your file.";
		}
	}
} else {
	if(!isset($_REQUEST["init"])) {
		echo "not init";
		return;
	}
	$opts = array(
			'http'=>array(
					'method'=>"GET",
					'header'=> implode("\r\n", array(
							'Content-type: text/plain; charset=UTF-8'							
					))
			)
	);
	$context = stream_context_create($opts);
	$str = file_get_contents($target_dir."naruto_db_en.json", false, $context);	
	
	$str = fixBadUnicodeForJson(chineseToUnicode($str));
	
	//$json = json_decode(fixBadUnicodeForJson($str));
	$json = json_decode($str, JSON_UNESCAPED_UNICODE);
	//header('Content-type: text/html; charset=UTF-8');		
	
	foreach($json["data"]["ninjas"] as $ninja) {
		$id_ninja = $ninja["iNid"];
		$name = $ninja["szName"];
		$nickname = $ninja["szNickname"];
		$attr = $ninja["szAttr"];
		$basicAttr = $ninja["szBasicAttr"];
		
		$attrs = explode('|', $basicAttr);
		$query = "INSERT INTO characters (name, alias, attribute, life, attack, defense, ninjutsu, resistance, id_json) VALUES "
				."('".pg_escape_string($name)."', '".pg_escape_string($nickname)."', '".$attr."', ".$attrs[0].", ".$attrs[1].", ".$attrs[2].", ".$attrs[3].", ".$attrs[4].", ".$id_ninja.") "
				."RETURNING id";

		$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$row = pg_fetch_row($result);
		$last_inserted_ninja_id = $row[0];
		
		insertSkill($json["data"]["skills"], $dbconn, $last_inserted_ninja_id, $ninja["mistery"]);
		insertSkill($json["data"]["skills"], $dbconn, $last_inserted_ninja_id, $ninja["standard"]);
		insertSkill($json["data"]["skills"], $dbconn, $last_inserted_ninja_id, $ninja["iBdSkill1"]);
		insertSkill($json["data"]["skills"], $dbconn, $last_inserted_ninja_id, $ninja["iBdSkill2"]);
		insertSkill($json["data"]["skills"], $dbconn, $last_inserted_ninja_id, $ninja["iBdSkill3"]);		
						
	}

	/*	
	while ($row = pg_fetch_row($result)) {
	  echo "name: $row[0] -> mistery: $row[1] -> $row[2]";
	  echo "<br />\n";
	}
*/	
}

function chineseToUnicode($str){
	//split word
	preg_match_all('/./u',$str,$matches);

	$c = "";
	foreach($matches[0] as $m){
		$c .= "\\u".bin2hex(iconv('UTF-8',"UCS-4",$m));
	}
	return $c;
}
function fixBadUnicodeForJson($str) {
	$str = preg_replace("/\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})/e", 'chr(hexdec("$1")).chr(hexdec("$2")).chr(hexdec("$3")).chr(hexdec("$4"))', $str);
	$str = preg_replace("/\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})/e", 'chr(hexdec("$1")).chr(hexdec("$2")).chr(hexdec("$3"))', $str);
	$str = preg_replace("/\\\\u000000([0-9a-f]{2})\\\\u000000([0-9a-f]{2})/e", 'chr(hexdec("$1")).chr(hexdec("$2"))', $str);
	$str = preg_replace("/\\\\u000000([0-9a-f]{2})/e", 'chr(hexdec("$1"))', $str);
	return $str;
}
function findSkill($skills, $field, $value)
{
	foreach($skills as $key => $skill)
	{
		if ( $skill[$field] === $value )
			return $key;
	}
	return false;
}

function insertSkill($skills, $dbconn, $ninja_id, $skill_id) {
	if($skill_id == 0)
		return;
	
	$skill_key = findSkill($skills, "iSkillId", $skill_id);
	$skill = $skills[$skill_key];
	
	switch($skill["iType"]) {
		case STANDARD:
			$type = 3;
			break;
		case MISTERY:
			$type = 1;
			break;
		case PASSIVE:
			$type = 4;
			break;
		case CHASE:
			$type = 2;
			break;
		default:
			$type = 3;
			break;
	}	
	
	$query = "SELECT id FROM skills WHERE id_json = '".$skill_id."';";
	$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
	$row = pg_fetch_row($result);
	if($row) {
		$last_inserted_skill_id = $row[0];
	} else {
		$query = "INSERT INTO skills (id_type, chase_status, hurt_status, hurt_num, pic_url, id_json) VALUES "
				."(".$type.", '".pg_escape_string($skill["szChaseStatus"])."', '".pg_escape_string($skill["szHurtStatus"])."', ".$skill["iHurtNum"].",'".pg_escape_string($skill["szPicUrl"])."', '".$skill_id."') "
						."RETURNING id";
		$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$skill_row = pg_fetch_row($result);
		$last_inserted_skill_id = $skill_row[0];
		
		$skill["szChaseStatus"] = trim(preg_replace('/-/i', '',$skill["szChaseStatus"]));
		if($skill["szChaseStatus"] != "") {
			
			$chases = explode(' ', $skill["szChaseStatus"]);				
			foreach($chases as $chase) {
				$query = "SELECT id FROM statuses WHERE alias = '".pg_escape_string($chase)."'";
				$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				$chase_row = pg_fetch_row($result);
		
				if($chase_row) {
					$query = "INSERT INTO skills_statuses (id_skill, id_status, chase_create) VALUES (".$last_inserted_skill_id.", ".$chase_row[0].", 1)";
					$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				}
			}
		}
		
		$skill["szHurtStatus"] = trim(preg_replace('/-/i', '',$skill["szHurtStatus"]));
		if($skill["szHurtStatus"] != "") {
			$hurts = explode(' ',$skill["szHurtStatus"]);
			foreach($hurts as $hurt) {
				$query = "SELECT id FROM statuses WHERE alias = '".pg_escape_string($hurt)."'";
				$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				$hurt_row = pg_fetch_row($result);
					
				if($hurt_row) {
					$query = "INSERT INTO skills_statuses (id_skill, id_status, chase_create) VALUES (".$last_inserted_skill_id.", ".$hurt_row[0].", 2)";
					$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				}
			}
		}
	}
	
	$query = "INSERT INTO characters_skills (id_character, id_skill) VALUES (".$ninja_id.", ".$last_inserted_skill_id.")";
	$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
}

function findNext($current, $attack, $ninjas, &$considered, &$high_combo_queue, &$combos, &$hits) {

	
	$toReturn = array();
	$summon_times = 0;
	if(count($attack["hurt_statuses"]) == 0)
			return $toReturn;
	
	$i = 0;
	foreach($ninjas as $ninja_key => $ninja) {
		foreach($attack["hurt_statuses"] as $create_key => $create) {
			foreach($ninja["chases"] as $chase_key => $chase) {
				foreach($chase["chase_statuses"] as $pursuit_key => $pursuit) {
					if(!isConsidered($ninja_key, $chase_key, $considered)) 
					{
						if($create["id"] == $pursuit["id"]) 
						{
							$combos++;
							//echo "<pre>";
							//echo "Found combo: from " .$current["name"]." [".$create["alias"]."] - [".$pursuit["alias"]."] ".$ninja["name"]."\n";
							//echo "</pre>";
							if(($ninja["human_summon"] == 2 && $ninja["summon_color"] == 'yellow' && $summon_times > 2) || $ninja["human_summon"] == 1) {
								$considered[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
							}
							if($ninja["human_summon"] == 2 && $ninja["summon_color"] == 'yellow' && $summon_times < 2) {
								$summon_times++;
							}
							$toReturn[] = $ninja["name"];
							if($i == 0)
								$hits += $attack["hurt_num"];
							
							$hits += $chase["hurt_num"];
							$toReturn = array_merge($toReturn, findNext($ninja, $chase, $ninjas, $considered, $high_combo_queue, $combos, $hits));
							break;
						}
						
						
						
						if($pursuit["alias"] == 'high_combo') 
						{
							$high_combo_queue[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
							$considered[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
						}
					}
				}
				if(count($toReturn) > 0)
					break;
			}
			if(count($toReturn) > 0)
				break;
		}
		if(count($toReturn) > 0)
			break;
		$i++;
	}
	return $toReturn;
}

function isConsidered($ninja_key, $chase_key, $considered) {	
	$return = false;
	foreach($considered as $cons_key => $cons_value) {
		if($cons_value['ninja_key'] == $ninja_key && $cons_value['chase_key'] == $chase_key) {
			$return = true;
			break;			
		}
	}
	return $return;
}

function ninjasLoop($ids, $dbconn, $i, &$highest_combo) {
	
	$considered = array();
	$high_combo_queue = array();
	$combos = 1;
	$ninjas = loadData($ids, $dbconn);
	$hits = 0;
	
	foreach($ninjas as $ninja) {
		
		//echo "<pre>";
		//echo "/************** ".$ninja["name"]."**************/\n";
		//echo "/************** Mistery **************/";
		//echo "</pre>";
		/************** Mistery **************/
		$considered = array();
		$high_combo_queue = array();
		$combos = 1;
		$hits = 0;
		findNext($ninja, $ninja["mistery"], $ninjas, $considered, $high_combo_queue, $combos, $hits);
		if($hits >= 10) {
			foreach($high_combo_queue as $key => $value) {
				$combos++;
			}
		}
		//echo "<pre>";
		//echo "Combos: ".$combos."\n";
		//echo "Hits: ".$hits."\n";
		//echo "</pre>";
		
		//echo "<pre>";
		//echo "/************** Standard **************/";
		//echo "</pre>";
		/************** Standard **************/		
		$considered = array();
		$high_combo_queue = array();
		$combos = 1;
		$hits = 0;
		findNext($ninja, $ninja["standard"], $ninjas, $considered, $high_combo_queue, $combos, $hits);
		if($hits >= 10) {
			foreach($high_combo_queue as $key => $value) {
				$combos++;
			}
		}
		//echo "<pre>";
		//echo "Combos: ".$combos."\n";
		//echo "Hits: ".$hits."\n";
		//echo "</pre>";
		if($combos > $highest_combo)
			$highest_combo = $combos;
		
		if($i < count($ids)) {
			$i++;
			array_push($ids, array_shift($ids));
			ninjasLoop($ids, $dbconn, $i, $highest_combo);
		}
	}
}

function loadData($ids = array(), $dbconn) {
	$ninjas = array();
	foreach($ids as $id) {
		//Get Ninjas mistery
		$query = "SELECT s.id, s.hurt_num FROM skills s "
				."LEFT OUTER JOIN characters_skills cs ON s.id = cs.id_skill "
						."LEFT OUTER JOIN characters c ON c.id = cs.id_character "
								."WHERE c.id = ".$id." AND id_type = 1";
		$result = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$row = pg_fetch_row($result);
		$mistery = $row[0];

		//Get Ninjas mistery hurt
		if(isset($mistery)) {
			$ninjas[$id]["mistery"]["hurt_num"] = $row[1];
			$query = "SELECT st.id, st.alias FROM statuses st "
					."LEFT OUTER JOIN skills_statuses ss ON st.id = ss.id_status "
							."LEFT OUTER JOIN skills s ON s.id = ss.id_skill "
									."WHERE s.id = ".$mistery." AND ss.chase_create = 2;";
			//echo $query."\n";
			$result2 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
			while ($row2 = pg_fetch_row($result2)) {
				$ninjas[$id]["mistery"]["hurt_statuses"][] = array("id" => $row2[0], "alias" => $row2[1]);
			}
		}

		//Get Ninjas standard
		$query = "SELECT s.id, s.hurt_num FROM skills s "
				."LEFT OUTER JOIN characters_skills cs ON s.id = cs.id_skill "
						."LEFT OUTER JOIN characters c ON c.id = cs.id_character "
								."WHERE c.id = ".$id." AND id_type = 3";
		$result3 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$row3 = pg_fetch_row($result3);
		$standard = $row3[0];
		//Get Ninjas standard hurt
		if(isset($standard)) {
			$ninjas[$id]["standard"]["hurt_num"] = $row3[1];
			$query = "SELECT st.id, st.alias FROM statuses st "
					."LEFT OUTER JOIN skills_statuses ss ON st.id = ss.id_status "
							."LEFT OUTER JOIN skills s ON s.id = ss.id_skill "
									."WHERE s.id = ".$standard." AND ss.chase_create = 2;";
			//echo $query."\n";
			$result4 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
			while ($row4 = pg_fetch_row($result4)) {
				$ninjas[$id]["standard"]["hurt_statuses"][] = array("id" => $row4[0], "alias" => $row4[1]);
			}
		}

		//Get Ninjas chase
		$query = "SELECT s.id, s.hurt_num FROM skills s "
				."LEFT OUTER JOIN characters_skills cs ON s.id = cs.id_skill "
						."LEFT OUTER JOIN characters c ON c.id = cs.id_character "
								."WHERE c.id = ".$id." AND id_type = 2";
		$result5 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$row5 = pg_fetch_row($result);
		$chases = array();
		while ($row5 = pg_fetch_row($result5)) {
			$chases[] = array("id" => $row5[0], "hurt_num" => $row5[1]);
		}

		//Get Ninjas chases hurt
		if(isset($chases)) {
			foreach($chases as $chase) {
				$ninjas[$id]["chases"][$chase["id"]]["hurt_num"] = $chase["hurt_num"];
				$query = "SELECT st.id, st.alias FROM statuses st "
						."LEFT OUTER JOIN skills_statuses ss ON st.id = ss.id_status "
								."LEFT OUTER JOIN skills s ON s.id = ss.id_skill "
										."WHERE s.id = ".$chase["id"]." AND ss.chase_create = 2;";
				//echo $query."\n";
				$result6 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				while ($row6 = pg_fetch_row($result6)) {
					$ninjas[$id]["chases"][$chase["id"]]["hurt_statuses"][] = array("id" => $row6[0], "alias" => $row6[1]);
				}

				$query = "SELECT st.id, st.alias FROM statuses st "
						."LEFT OUTER JOIN skills_statuses ss ON st.id = ss.id_status "
								."LEFT OUTER JOIN skills s ON s.id = ss.id_skill "
										."WHERE s.id = ".$chase["id"]." AND ss.chase_create = 1;";
				//echo $query."\n";
				$result7 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
				while ($row7 = pg_fetch_row($result7)) {
					$ninjas[$id]["chases"][$chase["id"]]["chase_statuses"][] = array("id" => $row7[0], "alias" => $row7[1]);
				}
			}
		}

		$query = "SELECT alias, life, attack, defense, ninjutsu, resistance, human_summon, summon_color FROM characters "
				."WHERE id = ".$id.";";
		$result8 = pg_query($dbconn, $query) or die($query."\n".pg_last_error($dbconn));
		$row8 = pg_fetch_row($result8);
		$ninjas[$id]["name"] = $row8[0];
		$ninjas[$id]["attributes"]["life"] = $row8[1];
		$ninjas[$id]["attributes"]["attack"] = $row8[2];
		$ninjas[$id]["attributes"]["defense"] = $row8[3];
		$ninjas[$id]["attributes"]["ninjutsu"] = $row8[4];
		$ninjas[$id]["attributes"]["resistance"] = $row8[5];
		$ninjas[$id]["human_summon"] = $row8[6];
		$ninjas[$id]["summon_color"] = $row8[7];

	}

	return $ninjas;
}


