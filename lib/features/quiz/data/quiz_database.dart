import 'package:adeen/features/quiz/domain/quiz_question.dart';

final List<QuizQuestion> quizQuestionsDb = _rawQuestions.map((json) => QuizQuestion.fromJson(json)).toList();

const List<Map<String, dynamic>> _rawQuestions = [
  {
    "id": 1,
    "category": "Prophets",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Prophet was swallowed by a giant fish or whale?",
    "options": ["Prophet Musa (AS)", "Prophet Yunus (AS)", "Prophet Nuh (AS)", "Prophet Isa (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Yunus (AS) was swallowed by a whale after leaving his people. Inside the whale, he prayed: 'Lailaha illa Anta, Subhanaka inni kuntu minaz-zalimin' (Quran 21:87), and Allah delivered him."
  },
  {
    "id": 2,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "Where were the first verses of the Holy Quran revealed to Prophet Muhammad (PBUH)?",
    "options": ["Masjid al-Haram", "Mount Sinai", "Cave of Hira", "Cave of Thawr"],
    "correct_option_index": 2,
    "tafsir_insight": "The first revelation came to Prophet Muhammad (PBUH) in the Cave of Hira on Mount al-Noor near Makkah, through Angel Jibril (AS) during the month of Ramadan."
  },
  {
    "id": 3,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which is the longest Surah in the Holy Quran?",
    "options": ["Surah Aal-E-Imran", "Surah Al-Baqarah", "Surah An-Nisa", "Surah Al-Ma'idah"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Baqarah (The Cow) is the 2nd Surah of the Quran and the longest, consisting of 286 verses."
  },
  {
    "id": 4,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet built the Ark to save believers from the great flood?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Nuh (AS)", "Prophet Hud (AS)", "Prophet Salih (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Nuh (AS) spent centuries calling his people to Allah. Under Allah's guidance, he built the Ark to carry believers and pairs of animals to safety from the global flood."
  },
  {
    "id": 5,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "Who rebuilt the Kaaba in Makkah with his son Ismail?",
    "options": ["Prophet Adam (AS)", "Prophet Ibrahim (AS)", "Prophet Nuh (AS)", "Prophet Dawud (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Ibrahim (AS) and his son Ismail (AS) raised the foundations of the Kaaba, praying for it to be a sanctuary of peace and monotheism (Quran 2:127)."
  },
  {
    "id": 6,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah is the only one in the Quran that does not start with Bismillah?",
    "options": ["Surah Al-Kahf", "Surah At-Tawbah", "Surah Al-Anfal", "Surah Maryam"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah At-Tawbah (repentance) does not begin with Bismillah. It was revealed as a declaration of security clearance and dissociation from polytheists."
  },
  {
    "id": 7,
    "category": "Prophets",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Prophet was given the miracle of parting the sea with his staff?",
    "options": ["Prophet Musa (AS)", "Prophet Harun (AS)", "Prophet Yusuf (AS)", "Prophet Lut (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "When fleeing Pharaoh, Prophet Musa (AS) was commanded to strike the sea with his staff. The water split, forming paths for the Children of Israel (Quran 26:63)."
  },
  {
    "id": 8,
    "category": "Quranic History",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the total number of Surahs in the Holy Quran?",
    "options": ["110", "114", "120", "100"],
    "correct_option_index": 1,
    "tafsir_insight": "The Holy Quran is composed of 114 Surahs (chapters), structured into 30 equal Juz (parts)."
  },
  {
    "id": 9,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet is known for his extraordinary patience through severe sickness and loss?",
    "options": ["Prophet Yaqub (AS)", "Prophet Ayyub (AS)", "Prophet Zakariya (AS)", "Prophet Yahya (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Ayyub (AS) lost his wealth, children, and health, yet remained patient and grateful, praying: 'Harm has touched me, and You are the most Merciful' (Quran 21:83)."
  },
  {
    "id": 10,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah is described by the Prophet (PBUH) as being equivalent to one-third of the Quran?",
    "options": ["Surah Al-Fatihah", "Surah Al-Ikhlas", "Surah Al-Mulk", "Surah Ya-Sin"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Ikhlas encapsulates pure monotheism (Tawhid) in four short verses, declaring Allah's oneness, absolute nature, and uniqueness."
  },
  {
    "id": 11,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which book of revelation was sent down to Prophet Dawud (AS)?",
    "options": ["Tawrah", "Injeel", "Zabur", "Suhuf"],
    "correct_option_index": 2,
    "tafsir_insight": "Allah revealed the Zabur (Psalms) to Prophet Dawud (AS), who had an exceptionally beautiful voice used to glorify Allah."
  },
  {
    "id": 12,
    "category": "Prophets",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Prophet could speak to animals and control wind and Jinn by Allah's leave?",
    "options": ["Prophet Sulaiman (AS)", "Prophet Dawud (AS)", "Prophet Yusuf (AS)", "Prophet Ibrahim (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Sulaiman (AS) was granted a kingdom like no other. He understood the language of birds, ants, and had dominion over wind and Jinn (Quran 27:16)."
  },
  {
    "id": 13,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "Under which Caliph's supervision was the official standardized script of the Quran compiled?",
    "options": ["Abu Bakr (RA)", "Umar (RA)", "Uthman (RA)", "Ali (RA)"],
    "correct_option_index": 2,
    "tafsir_insight": "Caliph Uthman ibn Affan (RA) ordered the standardization of the Quranic script (Mushaf) to preserve pronunciation unity across the expanding Islamic empire."
  },
  {
    "id": 14,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah contains two instances of Bismillah?",
    "options": ["Surah An-Naml", "Surah Yusuf", "Surah Hud", "Surah Al-Baqarah"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah An-Naml has Bismillah at the beginning (verse 1) and another inside verse 30, in the letter sent by Prophet Sulaiman to the Queen of Sheba."
  },
  {
    "id": 15,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Who was the mother of Prophet Ismail (AS)?",
    "options": ["Sarah", "Hajar", "Maryam", "Asiyah"],
    "correct_option_index": 1,
    "tafsir_insight": "Hajar (Hagar) was the mother of Prophet Ismail. When left in Makkah's valley, she ran between Safa and Marwa seeking water, leading to the spring of Zamzam."
  },
  {
    "id": 16,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the literal meaning of the word 'Quran'?",
    "options": ["The Book", "The Guidance", "The Recitation", "The Light"],
    "correct_option_index": 2,
    "tafsir_insight": "The word 'Quran' derives from the Arabic root 'Qara'a' meaning 'to read' or 'to recite'. Hence, Quran means 'The Recitation'."
  },
  {
    "id": 17,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah is recommended to be read every Friday to stay protected from the trial of Dajjal?",
    "options": ["Surah Ya-Sin", "Surah Al-Kahf", "Surah Al-Waqi'ah", "Surah Al-Mulk"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Muhammad (PBUH) stated that whoever recites Surah Al-Kahf (The Cave) on Friday will have light shining from beneath his feet to the clouds, and protection from Dajjal."
  },
  {
    "id": 18,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was thrown into a fire by his people but remained unharmed by Allah's command?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Ismail (AS)", "Prophet Ismail (AS)", "Prophet Musa (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "When Prophet Ibrahim (AS) rejected idols, King Nimrod's people threw him in fire. Allah commanded: 'O fire, be coolness and safety upon Ibrahim' (Quran 21:69)."
  },
  {
    "id": 19,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the shortest Surah in the Holy Quran?",
    "options": ["Surah Al-Ikhlas", "Surah Al-Kawthar", "Surah An-Nas", "Surah Al-Falaq"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Kawthar (The Abundance) consists of only 3 verses, making it the shortest Surah in the Quran."
  },
  {
    "id": 20,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet had a vision of eleven stars, the sun, and the moon bowing down to him?",
    "options": ["Prophet Yaqub (AS)", "Prophet Yusuf (AS)", "Prophet Ibrahim (AS)", "Prophet Ishaq (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Yusuf (AS) saw this dream as a child. The eleven stars represented his brothers, and the sun and moon represented his parents (Quran 12:4)."
  },
  {
    "id": 21,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "What was the first mosque built by Prophet Muhammad (PBUH) in Madinah?",
    "options": ["Masjid an-Nabawi", "Masjid al-Qiblatayn", "Masjid Quba", "Masjid al-Aqsa"],
    "correct_option_index": 2,
    "tafsir_insight": "Masjid Quba, located on the outskirts of Madinah, is the first mosque built by the Prophet (PBUH) and his companions during the Hijrah migration."
  },
  {
    "id": 22,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah is known as the 'Heart of the Quran'?",
    "options": ["Surah Ar-Rahman", "Surah Ya-Sin", "Surah Al-Fatihah", "Surah Al-Mulk"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Ya-Sin is widely called the heart of the Quran due to its intense focus on the core beliefs of Islam: Allah's oneness, message, and the afterlife."
  },
  {
    "id": 23,
    "category": "Quranic History",
    "difficulty": "Hard",
    "points": 20,
    "question": "What is the name of the scribe of the Prophet (PBUH) who led the initial compilation of the Quran?",
    "options": ["Zayd ibn Thabit (RA)", "Abdullah ibn Masud (RA)", "Ubayy ibn Ka'b (RA)", "Mu'adh ibn Jabal (RA)"],
    "correct_option_index": 0,
    "tafsir_insight": "Zayd ibn Thabit (RA) was appointed by Caliph Abu Bakr (RA) to collect and compile the Quran after many memorizers died in the Battle of Yamamah."
  },
  {
    "id": 24,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was born miraculously without a father?",
    "options": ["Prophet Yahya (AS)", "Prophet Isa (AS)", "Prophet Adam (AS)", "Prophet Idris (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Isa (AS), the son of Maryam (Mary), was created by Allah's command 'Kun' (Be), without a father (Quran 19:20-21)."
  },
  {
    "id": 25,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the primary theme of Surah Ar-Rahman?",
    "options": ["Rules of Inheritance", "Allah's Mercy and Blessings", "The Hypocrites", "Islamic Battles"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Ar-Rahman details Allah's abundant spiritual and physical blessings, repeating the refrain: 'Which of the favors of your Lord will you deny?'"
  },
  {
    "id": 26,
    "category": "Islamic Knowledge",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet killed the giant oppressor Jalut (Goliath)?",
    "options": ["Prophet Dawud (AS)", "Prophet Sulaiman (AS)", "Prophet Talut (AS)", "Prophet Musa (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Dawud (AS), while still a young soldier in Talut's army, defeated Jalut using a sling. He was later granted kingship and wisdom by Allah."
  },
  {
    "id": 27,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet is mentioned by name the most times in the Holy Quran?",
    "options": ["Prophet Muhammad (PBUH)", "Prophet Ibrahim (AS)", "Prophet Musa (AS)", "Prophet Isa (AS)"],
    "correct_option_index": 2,
    "tafsir_insight": "Prophet Musa (AS) is mentioned by name 136 times in the Holy Quran, with his story spanning numerous chapters."
  },
  {
    "id": 28,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah begins with a description of the Night Journey (Isra and Mi'raj)?",
    "options": ["Surah Al-Kahf", "Surah Al-Isra", "Surah An-Najm", "Surah At-Tur"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Isra (The Night Journey), also known as Surah Bani Isra'il, starts with: 'Glory to Him Who took His servant by night from Al-Masjid al-Haram to Al-Masjid al-Aqsa...'"
  },
  {
    "id": 29,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "To which ancient tribe was the Prophet Salih (AS) sent to guide?",
    "options": ["Ad", "Thamud", "Madyan", "Bani Isra'il"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Salih (AS) was sent to the people of Thamud, who carved elaborate dwellings from rocks. They rejected him and slaughtered the miraculous she-camel sent to them."
  },
  {
    "id": 30,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "What is the name of the mountain where the Ark of Prophet Nuh (AS) came to rest?",
    "options": ["Mount Sinai", "Mount Ararat", "Mount Judi", "Mount Uhud"],
    "correct_option_index": 2,
    "tafsir_insight": "Surah Hud verse 44 states that the Ark settled on Mount Judi (located in modern southeastern Turkey/Kurdistan) after the flood subsided."
  },
  {
    "id": 31,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "Who was the first woman to embrace Islam?",
    "options": ["Aisha (RA)", "Khadijah (RA)", "Fatimah (RA)", "Sumayyah (RA)"],
    "correct_option_index": 1,
    "tafsir_insight": "Khadijah bint Khuwaylid (RA), the first wife of Prophet Muhammad (PBUH), immediately believed in him and comforted him after the first revelation."
  },
  {
    "id": 32,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was given the miracle of bringing clay birds to life by Allah's permission?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Isa (AS)", "Prophet Musa (AS)", "Prophet Dawud (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Isa (AS) had many miracles detailed in Quran 3:49, including healing the blind, raising the dead, and animating clay figures into live birds, all by Allah's leave."
  },
  {
    "id": 33,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "In which Surah is the Verse of the Throne (Ayat al-Kursi) located?",
    "options": ["Surah Aal-E-Imran", "Surah Al-Baqarah", "Surah Yasin", "Surah Al-Mulk"],
    "correct_option_index": 1,
    "tafsir_insight": "Ayat al-Kursi is verse 255 of Surah Al-Baqarah, describing Allah's absolute power, self-subsistence, and comprehensive knowledge."
  },
  {
    "id": 34,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was known as the 'Friend of Allah' (Khalilullah)?",
    "options": ["Prophet Muhammad (PBUH)", "Prophet Ibrahim (AS)", "Prophet Musa (AS)", "Prophet Nuh (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Ibrahim (AS) was designated Khalilullah (Friend of Allah) because of his pure devotion, obedience, and struggles against polytheism."
  },
  {
    "id": 35,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "How many times is the name 'Muhammad' mentioned explicitly in the Holy Quran?",
    "options": ["4", "10", "25", "1"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Muhammad's (PBUH) name appears explicitly 4 times in the Quran (3:144, 33:40, 47:2, 48:29). The name Ahmad also appears once in 61:6."
  },
  {
    "id": 36,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah describes the events of the Year of the Elephant (Abrahah's attack on Kaaba)?",
    "options": ["Surah Al-Quraysh", "Surah Al-Fil", "Surah Al-Humazah", "Surah Al-Asr"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Fil (The Elephant) recounts how Allah destroyed the army of Abrahah, who rode elephants to demolish the Kaaba, by sending flocks of birds throwing baked stones."
  },
  {
    "id": 37,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet did Musa (AS) travel to learn from, as detailed in Surah Al-Kahf?",
    "options": ["Prophet Khidr (AS)", "Prophet Yusha (AS)", "Prophet Shuaib (AS)", "Prophet Harun (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Musa (AS) went on a journey with Al-Khidr (a servant of Allah with special knowledge) to learn patience and understand the hidden wisdom behind divine decrees."
  },
  {
    "id": 38,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "How many years did the revelation of the Holy Quran span?",
    "options": ["10 years", "23 years", "40 years", "30 years"],
    "correct_option_index": 1,
    "tafsir_insight": "The Quran was revealed gradually over a period of approximately 23 years, starting from the Prophet's age of 40 until his passing."
  },
  {
    "id": 39,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the opening Surah of the Holy Quran?",
    "options": ["Surah Al-Baqarah", "Surah Al-Fatihah", "Surah An-Nas", "Surah Al-Ikhlas"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Fatihah (The Opening) is the first Surah of the Quran, containing 7 verses. It is recited in every unit of the Islamic daily prayers."
  },
  {
    "id": 40,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Who was the father of Prophet Yusuf (AS)?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Ishaq (AS)", "Prophet Yaqub (AS)", "Prophet Ismail (AS)"],
    "correct_option_index": 2,
    "tafsir_insight": "Prophet Yaqub (Jacob, AS) was the father of Yusuf (AS). He grieved deeply and lost his eyesight due to sorrow after Yusuf was separated from him."
  },
  {
    "id": 41,
    "category": "Islamic Knowledge",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which city is the second holiest city in Islam, housing Masjid an-Nabawi?",
    "options": ["Makkah", "Jerusalem (Quds)", "Madinah", "Damascus"],
    "correct_option_index": 2,
    "tafsir_insight": "Madinah (formerly Yathrib) is the second holiest city, where Prophet Muhammad (PBUH) migrated, established the Islamic state, and was buried."
  },
  {
    "id": 42,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah contains the command for changing the Qiblah (direction of prayer) from Jerusalem to Makkah?",
    "options": ["Surah Aal-E-Imran", "Surah Al-Baqarah", "Surah An-Nisa", "Surah Al-Anfal"],
    "correct_option_index": 1,
    "tafsir_insight": "The command is in Surah Al-Baqarah verse 144: 'Turn your face toward Al-Masjid Al-Haram...', which was revealed to satisfy the Prophet's longing to face the Kaaba."
  },
  {
    "id": 43,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was sent to guide the tribe of 'Ad, who were known for their tall stature and great strength?",
    "options": ["Prophet Hud (AS)", "Prophet Salih (AS)", "Prophet Lut (AS)", "Prophet Shuaib (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Hud (AS) was sent to the tribe of 'Ad in the sands of Ahqaf. They rejected his call to monotheism and were destroyed by a devastating, cold wind storm."
  },
  {
    "id": 44,
    "category": "Quranic History",
    "difficulty": "Hard",
    "points": 20,
    "question": "What is the title given to the verses that were revealed BEFORE the migration (Hijrah) to Madinah?",
    "options": ["Madani", "Makki", "Suhuf", "Qudsi"],
    "correct_option_index": 1,
    "tafsir_insight": "Verses and Surahs revealed before the migration to Madinah are classified as 'Makki' (Meccan). They focus primarily on theology, beliefs, and the afterlife."
  },
  {
    "id": 45,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Who was the wife of Pharaoh who adopted and protected Prophet Musa (AS) as a baby?",
    "options": ["Hajar", "Asiyah", "Sarah", "Yukabid"],
    "correct_option_index": 1,
    "tafsir_insight": "Asiyah (RA), Pharaoh's wife, rescued Baby Musa from the river, convincing Pharaoh not to kill him. She is praised in the Quran as one of the ultimate women of faith."
  },
  {
    "id": 46,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "How many daily mandatory prayers (Salah) were decreed during the Night Journey (Isra and Mi'raj)?",
    "options": ["3", "5", "10", "50"],
    "correct_option_index": 1,
    "tafsir_insight": "Allah originally prescribed 50 daily prayers. After Prophet Musa (AS) urged Muhammad (PBUH) to request reductions, Allah decreased the number to 5 daily prayers while keeping the reward of 50."
  },
  {
    "id": 47,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah contains the verse: 'Indeed, with hardship will be ease'?",
    "options": ["Surah Ad-Duha", "Surah Ash-Sharh", "Surah At-Tin", "Surah Al-Alaq"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Ash-Sharh (The Relief, also Al-Inshirah) verses 5-6 repeats: 'For indeed, with hardship will be ease. Indeed, with hardship will be ease' to comfort the Prophet."
  },
  {
    "id": 48,
    "category": "Prophets",
    "difficulty": "Easy",
    "points": 10,
    "question": "Who is the first human being created by Allah and the father of mankind?",
    "options": ["Prophet Idris (AS)", "Prophet Nuh (AS)", "Prophet Adam (AS)", "Prophet Ibrahim (AS)"],
    "correct_option_index": 2,
    "tafsir_insight": "Prophet Adam (AS) was created from clay by Allah, who blew the soul into him. All angels were commanded to bow to him in honor of his knowledge."
  },
  {
    "id": 49,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah is also known as 'Al-Mu'awwidhatayn' along with Surah An-Nas?",
    "options": ["Surah Al-Falaq", "Surah Al-Ikhlas", "Surah Al-Kafirun", "Surah Al-Masad"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Falaq and Surah An-Nas together are called Al-Mu'awwidhatayn (the two Surahs of refuge) used for seeking protection from evils, magic, and envy."
  },
  {
    "id": 50,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "What is the primary language in which the Holy Quran was revealed?",
    "options": ["Hebrew", "Arabic", "Aramaic", "Persian"],
    "correct_option_index": 1,
    "tafsir_insight": "The Quran was revealed in Arabic to match the mother tongue of Prophet Muhammad (PBUH) and the pre-Islamic masters of eloquence (Quran 12:2)."
  },
  {
    "id": 51,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was sent to guide the people of Madyan, who were corrupt in business transactions?",
    "options": ["Prophet Shuaib (AS)", "Prophet Hud (AS)", "Prophet Lut (AS)", "Prophet Salih (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Shuaib (AS) preached to the people of Madyan (or the companions of the wood), telling them to give full measure and weight, and not cheat people of their goods."
  },
  {
    "id": 52,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which is the third holiest site in Islam, located in Jerusalem?",
    "options": ["Masjid an-Nabawi", "Masjid al-Aqsa", "Masjid Quba", "Masjid al-Qiblatayn"],
    "correct_option_index": 1,
    "tafsir_insight": "Masjid al-Aqsa is the third holiest sanctuary in Islam. It was the first Qiblah (direction of prayer) before it was redirected to Makkah."
  },
  {
    "id": 53,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah refers to the Quran as 'the Criterion' (Al-Furqan)?",
    "options": ["Surah Al-Furqan", "Surah Al-Kahf", "Surah Al-Hadid", "Surah Al-Hajj"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Furqan (The Criterion) is the 25th Surah, starting with: 'Blessed is He Who sent down the Criterion upon His servant that he may be to the worlds a warner.'"
  },
  {
    "id": 54,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet had a brother named Harun (Aaron), whom Allah appointed to assist him?",
    "options": ["Prophet Yusuf (AS)", "Prophet Musa (AS)", "Prophet Dawud (AS)", "Prophet Sulaiman (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "When Musa (AS) was commanded to face Pharaoh, he prayed for Harun (AS) to be his helper because Harun was more eloquent in speech (Quran 20:29-32)."
  },
  {
    "id": 55,
    "category": "Quranic History",
    "difficulty": "Hard",
    "points": 20,
    "question": "During which battle did the tragic martyrdom of many Quran memorizers trigger the initial compilation?",
    "options": ["Battle of Yamamah", "Battle of Uhud", "Battle of Badr", "Battle of Tabuk"],
    "correct_option_index": 0,
    "tafsir_insight": "In the Battle of Yamamah (against Musaylimah the liar), many Huffaz (memorizers) were killed, which concerned Umar (RA) and led to the collection of the Quran."
  },
  {
    "id": 56,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah is known as the 'Bride of the Quran' (Arus al-Quran)?",
    "options": ["Surah Yasin", "Surah Ar-Rahman", "Surah Al-Mulk", "Surah Al-Waqi'ah"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Ar-Rahman is called the 'Bride of the Quran' due to its beautiful, rhythmic style and description of Paradise."
  },
  {
    "id": 57,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet did King Nimrod try to argue with about who gives life and death?",
    "options": ["Prophet Musa (AS)", "Prophet Ibrahim (AS)", "Prophet Nuh (AS)", "Prophet Dawud (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Ibrahim (AS) told Nimrod: 'My Lord gives life and death.' Nimrod said: 'I give life and death.' Ibrahim then challenged him to bring the sun from the West."
  },
  {
    "id": 58,
    "category": "Islamic Knowledge",
    "difficulty": "Medium",
    "points": 15,
    "question": "In what year of the Hijri calendar did the Battle of Badr take place?",
    "options": ["1 AH", "2 AH", "3 AH", "5 AH"],
    "correct_option_index": 1,
    "tafsir_insight": "The Battle of Badr, the first major battle between Muslims and the Quraysh, took place on the 17th of Ramadan in 2 AH."
  },
  {
    "id": 59,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah translates to 'The Iron' and details the properties of metals sent down from heavens?",
    "options": ["Surah Al-Hadid", "Surah At-Tur", "Surah Al-Jathiyah", "Surah Al-Hajj"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Hadid (The Iron) verse 25 mentions: 'And We sent down iron, wherein is great military might and benefits for the people...'"
  },
  {
    "id": 60,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Who was the father of Prophet Ibrahim (AS), who carved idols?",
    "options": ["Azar", "Imran", "Lut", "Aazar"],
    "correct_option_index": 0,
    "tafsir_insight": "Quran 6:74 names Ibrahim's father as Azar, who was a high priest and idolatrous sculptor in ancient Babylon."
  },
  {
    "id": 61,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "What is the approximate number of verses (Ayat) in the Holy Quran?",
    "options": ["1000", "6236", "6666", "7777"],
    "correct_option_index": 1,
    "tafsir_insight": "There are exactly 6,236 numbered verses (Ayat) in the Holy Quran. Including the unnumbered Bismillahs, the count is slightly higher."
  },
  {
    "id": 62,
    "category": "Prophets",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Prophet is described as a good example or role model (Uswah Hasanah) for mankind?",
    "options": ["Prophet Musa (AS)", "Prophet Muhammad (PBUH)", "Prophet Ibrahim (AS)", "Prophet Isa (AS)"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Ahzab verse 21 states: 'Indeed, in the Messenger of Allah you have an excellent example (Uswah Hasanah) for whoever has hope in Allah...'"
  },
  {
    "id": 63,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah contains the verse: 'Verily, in the remembrance of Allah do hearts find rest'?",
    "options": ["Surah Ya-Sin", "Surah Ar-Ra'd", "Surah Ibrahim", "Surah Al-Hijr"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Ar-Ra'd (The Thunder) verse 28 details that believers are those who find peace in the remembrance (Dhikr) of Allah."
  },
  {
    "id": 64,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet migrated to Makkah along with his wife Sarah and nephew Lut?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Ishaq (AS)", "Prophet Ismail (AS)", "Prophet Yaqub (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Ibrahim (AS) traveled extensively across Mesopotamia, Egypt, Palestine, and Makkah to establish the message of monotheism."
  },
  {
    "id": 65,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which angel is responsible for bringing down the revelations (wahi) to the Prophets?",
    "options": ["Angel Mika'il", "Angel Israfil", "Angel Jibril (Gabriel)", "Angel Malakul-Maut"],
    "correct_option_index": 2,
    "tafsir_insight": "Angel Jibril (AS) is the trustworthy spirit (Ruh al-Amin) who brought down revelations from Allah to the hearts of the chosen messengers."
  },
  {
    "id": 66,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah is named after a mineral or precious stone and represents 'The Cave'?",
    "options": ["Surah Al-Hadid", "Surah Al-Kahf", "Surah An-Nur", "Surah Az-Zumar"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Al-Kahf (The Cave) recounts the story of the Sleepers of Ephesus, who slept in a cave for 309 years to escape religious persecution."
  },
  {
    "id": 67,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was thrown into a well by his jealous brothers?",
    "options": ["Prophet Yusuf (AS)", "Prophet Yaqub (AS)", "Prophet Ismail (AS)", "Prophet Ishaq (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Yusuf's brothers were jealous of their father's love for him. They plotted to throw him in a well, where a passing caravan rescued him."
  },
  {
    "id": 68,
    "category": "Quranic History",
    "difficulty": "Hard",
    "points": 20,
    "question": "What is the name of the valley where Prophet Musa (AS) was called by Allah through a burning bush?",
    "options": ["Valley of Makkah", "Valley of Tuwa", "Valley of Badr", "Valley of Arafah"],
    "correct_option_index": 1,
    "tafsir_insight": "Surah Taha verse 12 reveals: 'Indeed, I am your Lord, so remove your sandals. Indeed, you are in the sacred valley of Tuwa.'"
  },
  {
    "id": 69,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Sovereignty' and protects its reader from the punishment of the grave?",
    "options": ["Surah Al-Waqi'ah", "Surah Al-Mulk", "Surah Al-Muzzammil", "Surah Al-Muddaththir"],
    "correct_option_index": 1,
    "tafsir_insight": "Prophet Muhammad (PBUH) said that there is a Surah of 30 verses which intercedes for its reader until he is forgiven: Surah Al-Mulk."
  },
  {
    "id": 70,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was known for his beautiful voice, which caused mountains and birds to sing with him?",
    "options": ["Prophet Dawud (AS)", "Prophet Isa (AS)", "Prophet Yahya (AS)", "Prophet Sulaiman (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Allah subjected mountains and birds to glorify Him along with Prophet Dawud (AS) in the mornings and evenings (Quran 38:18-19)."
  },
  {
    "id": 71,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the name of the holy well near the Kaaba that emerged for baby Ismail and Hajar?",
    "options": ["Ab-e-Hayat", "Kauthar", "Zamzam", "Tasnim"],
    "correct_option_index": 2,
    "tafsir_insight": "The Zamzam well was generated by the heel of Angel Jibril striking the ground after Hajar's desperate search for water for her son Ismail."
  },
  {
    "id": 72,
    "category": "Surah Context",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Surah details the story of the owners of the garden who were tested with a blight because they wouldn't feed the poor?",
    "options": ["Surah Al-Qalam", "Surah Al-Mulk", "Surah Al-Haqqah", "Surah Al-Ma'arij"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Qalam verses 17-32 recounts the trial of the garden owners who swore to harvest at night to avoid giving charity, only to find it ruined."
  },
  {
    "id": 73,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet survived being cast into a pit of wild beasts or lions according to ancient traditions?",
    "options": ["Prophet Daniel (Danyal - AS)", "Prophet Zakariya (AS)", "Prophet Yahya (AS)", "Prophet Idris (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Danyal (AS), though not explicitly named in the Quran, is recognized in Islamic traditions as a major prophet who survived the lions' den."
  },
  {
    "id": 74,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "How many Sajdah (prostrations of recitation) are marked in the Holy Quran?",
    "options": ["10", "14", "20", "5"],
    "correct_option_index": 1,
    "tafsir_insight": "There are 14 (or 15, depending on the school of jurisprudence) Sajdah al-Tilawah marked in the Quran where prostration is recommended."
  },
  {
    "id": 75,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Light' and contains the famous 'Verse of Light' (Ayat al-Nur)?",
    "options": ["Surah An-Nur", "Surah Al-Hujurat", "Surah Al-Mujadilah", "Surah An-Najm"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah An-Nur verse 35 compares Allah's light to a niche containing a lamp, within a glass like a brilliant star."
  },
  {
    "id": 76,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was granted a son named Yahya in his very old age when his wife was barren?",
    "options": ["Prophet Zakariya (AS)", "Prophet Imran", "Prophet Ibrahim (AS)", "Prophet Ishaq (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Zakariya (AS) prayed for an heir to carry on the prophetic duties, and Allah blessed him with Yahya (AS) (Quran 19:7-9)."
  },
  {
    "id": 77,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the name of the gate of Paradise designated specifically for those who fast (Siyam)?",
    "options": ["Ar-Rayyan", "Al-Baab al-Akbar", "Baab as-Salah", "Baab az-Zuhd"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Muhammad (PBUH) stated: 'Indeed, in Paradise there is a gate called Ar-Rayyan, through which those who fast will enter on the Day of Resurrection.'"
  },
  {
    "id": 78,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah lists the 8 categories of people eligible to receive Zakat?",
    "options": ["Surah At-Tawbah", "Surah Al-Anfal", "Surah Al-Ma'idah", "Surah Al-Hadid"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah At-Tawbah verse 60 explicitly defines the recipients of charity (Zakat), including the poor, needy, and debtors."
  },
  {
    "id": 79,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Who was the cousin of Prophet Isa (AS) who was also a prophet?",
    "options": ["Prophet Yahya (AS)", "Prophet Zakariya (AS)", "Prophet Idris (AS)", "Prophet Yusha (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Yahya (John the Baptist) was the cousin of Prophet Isa (Jesus). They were contemporaries preaching to the Children of Israel."
  },
  {
    "id": 80,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "In which month of the Islamic calendar was the Holy Quran first revealed?",
    "options": ["Muharram", "Rajab", "Ramadan", "Dhul-Hijjah"],
    "correct_option_index": 2,
    "tafsir_insight": "Surah Al-Baqarah verse 185 states: 'The month of Ramadan is that in which was revealed the Quran, a guidance for the people...'"
  },
  {
    "id": 81,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Time' or 'The Declining Day' and warns that mankind is in loss except those of faith?",
    "options": ["Surah Al-Asr", "Surah Ad-Duha", "Surah Al-Layl", "Surah Ash-Shams"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Asr is a 3-verse Surah summarizing the path to salvation: faith, righteous deeds, truth, and patience."
  },
  {
    "id": 82,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet migrated from Egypt to Madyan, where he worked for 8 to 10 years before returning?",
    "options": ["Prophet Musa (AS)", "Prophet Yusuf (AS)", "Prophet Harun (AS)", "Prophet Isa (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "After accidentally killing an Egyptian, Musa (AS) fled to Madyan, married the daughter of a righteous man, and worked there before receiving revelation at Sinai."
  },
  {
    "id": 83,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "What is the direction of prayer (Qiblah) for Muslims?",
    "options": ["Jerusalem", "Kaaba in Makkah", "Al-Masjid an-Nabawi", "Mount Sinai"],
    "correct_option_index": 1,
    "tafsir_insight": "Muslims face the Kaaba in Makkah for all prayers. It is the geographic center point of unified Islamic worship."
  },
  {
    "id": 84,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah recounts the meeting between the Prophet Sulaiman (AS) and the Queen of Sheba (Bilqis)?",
    "options": ["Surah An-Naml", "Surah Saba", "Surah Sad", "Surah Fatir"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah An-Naml (The Ants) details how a hoopoe bird reported Sheba's sun-worshipping queen, leading Sulaiman (AS) to invite her to submit to Allah."
  },
  {
    "id": 85,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was raised to the heavens alive by Allah to save him from crucifixion?",
    "options": ["Prophet Isa (AS)", "Prophet Idris (AS)", "Prophet Yahya (AS)", "Prophet Zakariya (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah An-Nisa verses 157-158 explains: 'And they did not kill him, nor did they crucify him... Rather, Allah raised him to Himself.'"
  },
  {
    "id": 86,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "What is the term for the classification of Surahs revealed AFTER the migration to Madinah?",
    "options": ["Makki", "Madani", "Suhuf", "Qudsi"],
    "correct_option_index": 1,
    "tafsir_insight": "Surahs revealed after the Hijrah are 'Madani'. They deal primarily with legislation, community guidelines, laws, and state relations."
  },
  {
    "id": 87,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Great Event' or 'The Inevitable' and describes the three groups on the Day of Judgment?",
    "options": ["Surah Al-Waqi'ah", "Surah Al-Qari'ah", "Surah Al-Ghashiyah", "Surah An-Naba"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Waqi'ah describes the division of mankind into the Foremost, the companions of the Right, and the companions of the Left."
  },
  {
    "id": 88,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was commanded to sacrifice his son as a trial of faith?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Ishaq (AS)", "Prophet Yaqub (AS)", "Prophet Nuh (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Ibrahim (AS) saw a dream command to sacrifice his son Ismail. Both complied with submission, after which Allah replaced the boy with a ram."
  },
  {
    "id": 89,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "How many pillars of faith (Iman) are there in Islam?",
    "options": ["5", "6", "7", "4"],
    "correct_option_index": 1,
    "tafsir_insight": "There are 6 pillars of Iman: belief in Allah, His Angels, His Books, His Messengers, the Last Day, and Divine Decree (Qadar)."
  },
  {
    "id": 90,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah ends with a list of the attributes of Allah, concluding with 'He is Allah, the Creator, the Inventor, the Fashioner'?",
    "options": ["Surah Al-Hashr", "Surah Al-Hadid", "Surah Al-Mumtahanah", "Surah As-Saff"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Hashr verses 22-24 lists numerous Names of Allah, emphasizing His supremacy, peace, majesty, and creative attributes."
  },
  {
    "id": 91,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet is described as a precursor to Prophet Isa (AS) who announced his coming?",
    "options": ["Prophet Yahya (AS)", "Prophet Zakariya (AS)", "Prophet Yusha (AS)", "Prophet Idris (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Yahya (AS) validated the words of Maryam and was the first to witness to the truth of Prophet Isa (AS) (Quran 3:39)."
  },
  {
    "id": 92,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "In what location is the original compiled copy of the Quran from the Uthmanic Caliphate preserved today?",
    "options": ["Topkapi Palace (Istanbul)", "Makkah Museum", "British Museum", "Cairo Library"],
    "correct_option_index": 0,
    "tafsir_insight": "One of the original personal manuscripts of Caliph Uthman (RA), containing his bloodstains from his martyrdom, is held in the Topkapi Palace Museum in Istanbul."
  },
  {
    "id": 93,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Cleaving' or 'The Shattering' and describes the sky splitting on the Day of Judgment?",
    "options": ["Surah Infitar", "Surah Inshiqaq", "Surah Takwir", "Surah Naziat"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Al-Infitar begins: 'When the sky splits open (cleaves)...', describing the physical breaking of universal order."
  },
  {
    "id": 94,
    "category": "Prophets",
    "difficulty": "Medium",
    "points": 15,
    "question": "Which Prophet was known as 'Dhun-Nun' (The Companion of the Fish)?",
    "options": ["Prophet Yunus (AS)", "Prophet Yusuf (AS)", "Prophet Yaqub (AS)", "Prophet Isa (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Quran 21:87 calls Prophet Yunus (AS) 'Dhun-Nun' (He of the fish) because of his trial in the whale."
  },
  {
    "id": 95,
    "category": "Islamic Knowledge",
    "difficulty": "Easy",
    "points": 10,
    "question": "How many pillars of Islam (practice) are there?",
    "options": ["5", "6", "7", "4"],
    "correct_option_index": 0,
    "tafsir_insight": "There are 5 pillars of Islam: Shahadah (Faith), Salah (Prayer), Zakat (Almsgiving), Sawm (Fasting), and Hajj (Pilgrimage)."
  },
  {
    "id": 96,
    "category": "Surah Context",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Surah is the only one named after a woman?",
    "options": ["Surah Maryam", "Surah An-Nisa", "Surah Al-Mujadilah", "Surah Al-Mumtahanah"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Maryam (Mary) is the 19th Surah, honoring the mother of Prophet Isa (AS) and detailing her miraculous pregnancy."
  },
  {
    "id": 97,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet was chosen by Allah to ascend to the seventh heaven in bodily form (Mi'raj)?",
    "options": ["Prophet Muhammad (PBUH)", "Prophet Isa (AS)", "Prophet Musa (AS)", "Prophet Ibrahim (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Muhammad (PBUH) made the Night Journey to Jerusalem and was then raised through the celestial spheres, meeting other Prophets and receiving prayers."
  },
  {
    "id": 98,
    "category": "Quranic History",
    "difficulty": "Medium",
    "points": 15,
    "question": "What is the term for the collections of the Prophet's (PBUH) words and actions that clarify the Quran?",
    "options": ["Hadith", "Tafsir", "Fiqh", "Seerah"],
    "correct_option_index": 0,
    "tafsir_insight": "Hadith reports record the Sunnah (traditions and practices) of Prophet Muhammad (PBUH) which serve as the second source of Islamic law."
  },
  {
    "id": 99,
    "category": "Surah Context",
    "difficulty": "Easy",
    "points": 10,
    "question": "Which Surah translates to 'The Morning Hours' or 'The Bright Morning' and comforted the Prophet during a pause in revelation?",
    "options": ["Surah Ad-Duha", "Surah Ash-Sharh", "Surah Al-Layl", "Surah At-Tin"],
    "correct_option_index": 0,
    "tafsir_insight": "Surah Ad-Duha comforted the Prophet when revelations stopped briefly and pagan mockers said his Lord had abandoned him."
  },
  {
    "id": 100,
    "category": "Prophets",
    "difficulty": "Hard",
    "points": 20,
    "question": "Which Prophet is known as the father of the Arab peoples through his son Ismail (AS)?",
    "options": ["Prophet Ibrahim (AS)", "Prophet Ishaq (AS)", "Prophet Nuh (AS)", "Prophet Yaqub (AS)"],
    "correct_option_index": 0,
    "tafsir_insight": "Prophet Ibrahim (AS) is the patriarch of both the Arabs (through Ismail AS) and the Children of Israel (through Ishaq AS)."
  }
];
