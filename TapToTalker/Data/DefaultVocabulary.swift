import Foundation

enum DefaultVocabulary {
    static let emojiByID: [String: String] = [
        "animal": "🐶", "angry": "😠", "answer": "✅", "apple": "🍎",
        "bathroom": "🚽", "bed": "🛏️", "blanket": "🧣", "body": "🧍",
        "break": "⏸️", "car": "🚗", "caregiver": "🤝", "chair": "🪑",
        "chicken": "🍗", "confused": "❓", "cookies": "🍪", "dad": "👨",
        "doctor": "🩺", "drawing": "🎨", "drink": "🥤", "eat": "🍽️",
        "excited": "🤩", "feel": "🙂", "finished": "🏁", "food": "🍽️",
        "friend": "🧑‍🤝‍🧑", "game": "🎮", "go": "📍", "happy": "😊",
        "hear": "👂", "help": "🆘", "home": "🏠", "not-okay": "🙁",
        "ice-cream": "🍨", "ice": "🧊", "juice": "🧃", "big": "➕",
        "chocolate": "🍫", "cold": "🧊", "lights-off": "🌙", "loud": "🔊",
        "maybe": "🤔", "medicine": "💊", "milk": "🥛", "mom": "👩",
        "more": "➕", "music": "🎵", "need": "💬", "no": "👎",
        "outside": "☀️", "pain": "🤕", "person": "🧍", "pizza": "🍕",
        "play": "🎮", "quiet": "🤫", "read": "📖", "rest": "🛏️",
        "sad": "😢", "sandwich": "🥪", "scared": "😟", "see": "👁️",
        "sick": "🤒", "something-scary": "⚠️", "space": "🌬️", "stop": "🛑",
        "strawberry": "🍓", "stuck": "🚫", "strips": "🍗", "talk": "💬",
        "teacher": "👩‍🏫", "tired": "😴", "voice": "🗣️", "want": "❤️",
        "warm-drink": "☕", "warm": "♨️", "water": "💧", "yes": "👍",
        "nuggets": "🍗", "vanilla": "🍨", "small": "💧", "no-ice": "🚫",
        "pillow": "🛏️"
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
                        card("warm", "Warm", minMode: .advanced),
                        card("cold", "Cold", minMode: .advanced)
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
                card("rest", "Rest", prompt: "Where do you want to rest?", options: [
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
                    card("game", "Game"),
                    card("music", "Music"),
                    card("drawing", "Drawing"),
                    card("read", "Read")
                ]),
                card("go", "Go to", prompt: "Where do you want to go?", options: [
                    card("bathroom", "Bathroom"),
                    card("outside", "Outside"),
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
                card("excited", "Excited"),
                card("tired", "Tired"),
                card("sick", "Sick"),
                card("sad", "Sad"),
                card("scared", "Scared"),
                card("angry", "Angry"),
                card("confused", "Confused")
            ]),
            card("need", "I need", prompt: "What do you need?", options: [
                card("water", "Water"),
                card("food", "Food"),
                card("help", "Help"),
                card("bathroom", "Bathroom"),
                card("break", "Break"),
                card("medicine", "Medicine"),
                card("blanket", "Blanket"),
                card("space", "Space")
            ]),
            card("person", "I want", prompt: "Who do you want?", options: [
                card("mom", "Mom"),
                card("dad", "Dad"),
                card("friend", "Friend"),
                card("teacher", "Teacher"),
                card("doctor", "Doctor"),
                card("caregiver", "Caregiver")
            ]),
            card("answer", "Answer", prompt: "Choose an answer", options: [
                card("yes", "Yes"),
                card("no", "No"),
                card("maybe", "Maybe"),
                card("more", "More"),
                card("finished", "Finished"),
                card("stop", "Stop")
            ]),
            card("not-okay", "Not okay", prompt: "What is wrong?", options: [
                card("sick", "Sick"),
                card("scared", "Scared"),
                card("loud", "Too loud"),
                card("tired", "Tired"),
                card("body", "Body"),
                card("help", "Need help")
            ]),
            card("see", "I see", prompt: "What do you see?", options: [
                card("person", "Person"),
                card("animal", "Animal"),
                card("car", "Car"),
                card("food", "Food"),
                card("outside", "Outside"),
                card("something-scary", "Scary thing")
            ]),
            card("hear", "I hear", prompt: "What do you hear?", options: [
                card("music", "Music"),
                card("loud", "Loud sound"),
                card("voice", "Voice"),
                card("quiet", "Quiet")
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
