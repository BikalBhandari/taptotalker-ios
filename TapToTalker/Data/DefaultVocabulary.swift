import Foundation

enum DefaultVocabulary {
    /// Default AAC card symbols (Unicode). Bundled OpenMoji artwork is resolved from these at display time.
    static let emojiByID: [String: String] = [
        // Starters
        "want": "🙋", "feel": "😊", "need": "✋", "person": "👥",
        "answer": "🆗", "not-okay": "😣", "see": "👀", "hear": "👂",
        // Feelings
        "happy": "😄", "sad": "😢", "angry": "😠", "scared": "😨",
        "tired": "😴", "sick": "🤒", "excited": "🤩", "calm": "😌",
        // People
        "mom": "👩", "dad": "👨", "brother": "👦", "sister": "👧",
        "grandma": "👵", "grandpa": "👴", "friend": "🫂", "teacher": "👩‍🏫",
        "doctor": "🧑‍⚕️", "caregiver": "🤗",
        // Food & drink
        "eat": "🍎", "food": "🍎", "drink": "🥤", "cookies": "🍪",
        "chicken": "🍗", "nuggets": "🍗", "strips": "🍗", "wings": "🍗",
        "sandwich": "🥪", "chicken-sandwich": "🥪", "pizza": "🍕", "apple": "🍎",
        "ice-cream": "🍦", "vanilla": "🍦", "chocolate": "🍫", "strawberry": "🍓",
        "water": "💧", "juice": "🧃", "milk": "🥛", "warm-drink": "☕",
        "ice": "🧊", "no-ice": "🚫", "small": "🔽", "big": "🔼",
        // Places & sleep
        "go": "🚶", "bathroom": "🚻", "outside": "🌳", "car": "🚗",
        "home": "🏠", "chair": "🪑", "sleep": "😴", "bed": "🛏️",
        "blanket": "🛏️", "pillow": "🛏️", "lights-off": "🌑",
        "walk": "🚶", "park": "🏞️",
        // Play & senses
        "play": "🎲", "game": "🎮", "video-game": "🎮", "board-game": "🎲",
        "ball": "⚽", "music": "🎵", "drawing": "🎨", "read": "📖",
        "animal": "🐶", "quiet": "🤫", "voice": "🗣️", "loud": "📢",
        "something-scary": "👻", "toy": "🧸", "screen": "📱",
        "my-name": "📛", "tv": "📺",
        // Needs & answers
        "help": "🆘", "talk": "💬", "pain": "🤕", "hurt": "🤕",
        "head": "🗣️", "tummy": "🤢", "other": "💪",
        "stuck": "🧱", "break": "⏸️", "medicine": "💊", "hug": "🤗",
        "yes": "👍", "no": "👎", "maybe": "🤷", "more": "➕",
        "finished": "🏁", "stop": "🛑", "again": "🔁", "wait": "⏳",
        "too-bright": "🔆"
    ]

    static func emoji(for id: String) -> String {
        emojiByID[id] ?? "🔹"
    }

    static let root: BoardNode = BoardNode(
        prompt: "Choose a message starter",
        options: [
            card("want", "I want to", prompt: "What do you want?", options: [
                card("eat", "Eat", prompt: "What would you like to eat?", options: [
                    card("cookies", "Cookies"),
                    card("chicken", "Chicken", options: [
                        card("nuggets", "Nuggets", minMode: .advanced),
                        card("strips", "Strips", minMode: .advanced),
                        card("chicken-sandwich", "Sandwich", minMode: .advanced),
                        card("wings", "Wings", minMode: .advanced)
                    ]),
                    card("sandwich", "Sandwich"),
                    card("pizza", "Pizza"),
                    card("apple", "Apple"),
                    card("ice-cream", "Ice cream", options: [
                        card("vanilla", "Vanilla", minMode: .advanced),
                        card("chocolate", "Chocolate", minMode: .advanced),
                        card("strawberry", "Strawberry", minMode: .advanced)
                    ])
                ]),
                card("drink", "Drink", prompt: "What would you like to drink?", options: [
                    card("water", "Water", options: [
                        card("small", "Small", minMode: .advanced),
                        card("big", "Big", minMode: .advanced),
                        card("ice", "Ice", minMode: .advanced),
                        card("no-ice", "No ice", minMode: .advanced)
                    ]),
                    card("juice", "Juice"),
                    card("milk", "Milk"),
                    card("warm-drink", "Warm drink")
                ]),
                card("sleep", "Sleep", prompt: "Where do you want to sleep?", options: [
                    card("bed", "Bed", options: [
                        card("blanket", "Blanket", minMode: .advanced),
                        card("pillow", "Pillow", minMode: .advanced),
                        card("lights-off", "Lights off", minMode: .advanced)
                    ]),
                    card("chair", "Chair"),
                    card("home", "Home"),
                    card("quiet", "Quiet room")
                ]),
                card("play", "Play", prompt: "What do you want to play?", options: [
                    card("game", "Game", options: [
                        card("video-game", "Video game", minMode: .advanced),
                        card("board-game", "Board game", minMode: .advanced),
                        card("ball", "Ball", minMode: .advanced)
                    ]),
                    card("music", "Music"),
                    card("drawing", "Drawing"),
                    card("read", "Read")
                ]),
                card("go", "Go to", prompt: "Where do you want to go?", options: [
                    card("bathroom", "Bathroom"),
                    card("outside", "Outside", options: [
                        card("walk", "Walk", minMode: .advanced),
                        card("park", "Park", minMode: .advanced)
                    ]),
                    card("car", "Car"),
                    card("home", "Home")
                ]),
                card("help", "Get help", prompt: "What help do you need?", options: [
                    card("pain", "Pain"),
                    card("bathroom", "Bathroom"),
                    card("talk", "Talk", options: [
                        card("mom", "Mom", minMode: .advanced),
                        card("dad", "Dad", minMode: .advanced),
                        card("teacher", "Teacher", minMode: .advanced),
                        card("caregiver", "Caregiver", minMode: .advanced)
                    ]),
                    card("stuck", "Stuck")
                ])
            ]),
            card("feel", "I feel", prompt: "How do you feel?", options: [
                card("happy", "Happy"),
                card("sad", "Sad"),
                card("angry", "Angry"),
                card("scared", "Scared"),
                card("tired", "Tired"),
                card("sick", "Sick"),
                card("excited", "Excited"),
                card("calm", "Calm")
            ]),
            card("need", "I need", prompt: "What do you need?", options: [
                card("water", "Water"),
                card("food", "Food"),
                card("bathroom", "Bathroom"),
                card("help", "Help"),
                card("break", "Break"),
                card("hug", "Hug"),
                card("medicine", "Medicine"),
                card("quiet", "Quiet")
            ]),
            card("person", "I want", prompt: "Who do you want?", options: [
                card("mom", "Mom"),
                card("dad", "Dad"),
                card("brother", "Brother"),
                card("sister", "Sister"),
                card("grandma", "Grandma"),
                card("grandpa", "Grandpa"),
                card("friend", "Friend"),
                card("teacher", "Teacher"),
                card("doctor", "Doctor")
                // Caregiver stays under Get help → Talk (keeps this screen ≤ 9 tiles)
            ]),
            card("answer", "Answer", prompt: "Choose an answer", options: [
                card("yes", "Yes"),
                card("no", "No"),
                card("maybe", "Maybe"),
                card("more", "More"),
                card("finished", "Finished"),
                card("stop", "Stop"),
                card("again", "Again"),
                card("wait", "Wait")
            ]),
            card("not-okay", "Not okay", prompt: "What is wrong?", options: [
                card("hurt", "Hurt", options: [
                    card("head", "Head", minMode: .advanced),
                    card("tummy", "Tummy", minMode: .advanced),
                    card("other", "Other", minMode: .advanced)
                ]),
                card("sick", "Sick"),
                card("loud", "Too loud"),
                card("too-bright", "Too bright"),
                card("scared", "Scared"),
                card("help", "Need help")
            ]),
            card("see", "I see", prompt: "What do you see?", options: [
                card("person", "Person"),
                card("animal", "Animal"),
                card("car", "Car"),
                card("food", "Food"),
                card("toy", "Toy"),
                card("outside", "Outside"),
                card("something-scary", "Scary thing"),
                card("screen", "Screen")
            ]),
            card("hear", "I hear", prompt: "What do you hear?", options: [
                card("music", "Music"),
                card("voice", "Voice"),
                card("loud", "Loud sound"),
                card("quiet", "Quiet"),
                card("my-name", "My name"),
                card("tv", "TV")
            ])
        ]
    )

    private static func card(
        _ id: String,
        _ label: String,
        prompt: String? = nil,
        minMode: VocabularyMode? = nil,
        options: [AACCard] = []
    ) -> AACCard {
        AACCard(
            id: id,
            label: label,
            emoji: emoji(for: id),
            prompt: prompt,
            minMode: minMode,
            options: options
        )
    }
}
