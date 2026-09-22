import Foundation

enum DefaultVocabulary {
    /// Clearer, more distinct AAC emoji cues by category.
    static let emojiByID: [String: String] = [
        // Starters
        "want": "🙋", "feel": "💭", "need": "🙏", "person": "👤",
        "answer": "💬", "not-okay": "😟", "see": "👀", "hear": "👂",
        // Want → actions
        "eat": "🍽️", "drink": "🥤", "rest": "😴", "play": "🎈",
        "go": "🚶", "help": "🆘",
        // Food
        "cookies": "🍪", "chicken": "🍗", "nuggets": "🥡", "strips": "🥓",
        "warm": "♨️", "cold": "🥶", "sandwich": "🥪", "pizza": "🍕",
        "apple": "🍎", "ice-cream": "🍦", "vanilla": "🍨", "chocolate": "🍫",
        "strawberry": "🍓", "food": "🍱",
        // Drink
        "water": "💧", "small": "🧴", "big": "🫙", "ice": "🧊",
        "no-ice": "🚫", "juice": "🧃", "milk": "🥛", "warm-drink": "☕",
        // Rest / places
        "bed": "🛏️", "blanket": "🧸", "pillow": "🛌", "lights-off": "🌙",
        "chair": "🪑", "home": "🏠", "quiet": "🤫", "bathroom": "🚽",
        "outside": "🌳", "car": "🚗",
        // Play
        "game": "🎮", "music": "🎵", "drawing": "🎨", "read": "📚",
        // Help / people
        "pain": "🤕", "talk": "🗣️", "stuck": "🚧", "mom": "👩",
        "dad": "👨", "teacher": "👩‍🏫", "caregiver": "🧑‍⚕️", "friend": "🤗",
        "doctor": "🩺",
        // Feelings
        "happy": "😄", "excited": "🤩", "tired": "🥱", "sick": "🤒",
        "sad": "😢", "scared": "😨", "angry": "😠", "confused": "😕",
        // Needs
        "break": "⏸️", "medicine": "💊", "space": "🌌",
        // Answers
        "yes": "👍", "no": "👎", "maybe": "🤔", "more": "➕",
        "finished": "✅", "stop": "🛑",
        // Not okay / senses
        "loud": "🔊", "body": "🧍", "animal": "🐾",
        "something-scary": "👻", "voice": "🎙️"
    ]

    static let toneByID: [String: CardTone] = [
        "want": .rose, "feel": .yellow, "need": .sky, "person": .emerald,
        "answer": .teal, "not-okay": .orange, "see": .violet, "hear": .indigo,
        "eat": .amber, "drink": .cyan, "rest": .indigo, "play": .violet,
        "go": .emerald, "help": .rose,
        "cookies": .amber, "chicken": .orange, "sandwich": .yellow, "pizza": .rose,
        "apple": .emerald, "ice-cream": .violet,
        "water": .sky, "juice": .orange, "milk": .teal, "warm-drink": .amber,
        "happy": .yellow, "excited": .amber, "tired": .indigo, "sick": .rose,
        "sad": .sky, "scared": .orange, "angry": .rose, "confused": .violet,
        "yes": .emerald, "no": .rose, "maybe": .violet, "more": .cyan,
        "finished": .teal, "stop": .orange,
        "mom": .rose, "dad": .sky, "friend": .yellow, "teacher": .cyan,
        "doctor": .teal, "caregiver": .emerald
    ]

    static func emoji(for id: String) -> String {
        emojiByID[id] ?? "🔹"
    }

    static func tone(for id: String, fallback: CardTone? = nil) -> CardTone {
        toneByID[id] ?? fallback ?? CardTone.inferred(for: id)
    }

    static let root: BoardNode = BoardNode(
        prompt: "Choose a message starter",
        options: [
            card("want", "I want to", tone: .rose, prompt: "What do you want?", options: [
                card("eat", "Eat", tone: .amber, prompt: "What would you like to eat?", options: [
                    card("cookies", "Cookies", tone: .amber),
                    card("chicken", "Chicken", tone: .orange, options: [
                        card("nuggets", "Nuggets", tone: .orange, minMode: .advanced),
                        card("strips", "Strips", tone: .amber, minMode: .advanced),
                        card("warm", "Warm", tone: .rose, minMode: .advanced),
                        card("cold", "Cold", tone: .sky, minMode: .advanced)
                    ]),
                    card("sandwich", "Sandwich", tone: .yellow),
                    card("pizza", "Pizza", tone: .rose),
                    card("apple", "Apple", tone: .emerald),
                    card("ice-cream", "Ice cream", tone: .violet, options: [
                        card("vanilla", "Vanilla", tone: .yellow, minMode: .advanced),
                        card("chocolate", "Chocolate", tone: .orange, minMode: .advanced),
                        card("strawberry", "Strawberry", tone: .rose, minMode: .advanced)
                    ])
                ]),
                card("drink", "Drink", tone: .cyan, prompt: "What would you like to drink?", options: [
                    card("water", "Water", tone: .sky, options: [
                        card("small", "Small", tone: .sky, minMode: .advanced),
                        card("big", "Big", tone: .cyan, minMode: .advanced),
                        card("ice", "Ice", tone: .teal, minMode: .advanced),
                        card("no-ice", "No ice", tone: .violet, minMode: .advanced)
                    ]),
                    card("juice", "Juice", tone: .orange),
                    card("milk", "Milk", tone: .teal),
                    card("warm-drink", "Warm drink", tone: .amber)
                ]),
                card("rest", "Rest", tone: .indigo, prompt: "Where do you want to rest?", options: [
                    card("bed", "Bed", tone: .indigo, options: [
                        card("blanket", "Blanket", tone: .violet, minMode: .advanced),
                        card("pillow", "Pillow", tone: .sky, minMode: .advanced),
                        card("lights-off", "Lights off", tone: .indigo, minMode: .advanced)
                    ]),
                    card("chair", "Chair", tone: .teal),
                    card("home", "Home", tone: .emerald),
                    card("quiet", "Quiet room", tone: .violet)
                ]),
                card("play", "Play", tone: .violet, prompt: "What do you want to play?", options: [
                    card("game", "Game", tone: .emerald),
                    card("music", "Music", tone: .violet),
                    card("drawing", "Drawing", tone: .rose),
                    card("read", "Read", tone: .cyan)
                ]),
                card("go", "Go to", tone: .emerald, prompt: "Where do you want to go?", options: [
                    card("bathroom", "Bathroom", tone: .teal),
                    card("outside", "Outside", tone: .yellow),
                    card("car", "Car", tone: .sky),
                    card("home", "Home", tone: .emerald)
                ]),
                card("help", "Get help", tone: .rose, prompt: "What help do you need?", options: [
                    card("pain", "Pain", tone: .rose),
                    card("bathroom", "Bathroom", tone: .teal),
                    card("talk", "Talk", tone: .yellow, options: [
                        card("mom", "Mom", tone: .rose, minMode: .advanced),
                        card("dad", "Dad", tone: .sky, minMode: .advanced),
                        card("teacher", "Teacher", tone: .cyan, minMode: .advanced),
                        card("caregiver", "Caregiver", tone: .emerald, minMode: .advanced)
                    ]),
                    card("stuck", "Stuck", tone: .orange)
                ])
            ]),
            card("feel", "I feel", tone: .yellow, prompt: "How do you feel?", options: [
                card("happy", "Happy", tone: .yellow),
                card("excited", "Excited", tone: .amber),
                card("tired", "Tired", tone: .indigo),
                card("sick", "Sick", tone: .rose),
                card("sad", "Sad", tone: .sky),
                card("scared", "Scared", tone: .orange),
                card("angry", "Angry", tone: .rose),
                card("confused", "Confused", tone: .violet)
            ]),
            card("need", "I need", tone: .sky, prompt: "What do you need?", options: [
                card("water", "Water", tone: .sky),
                card("food", "Food", tone: .amber),
                card("help", "Help", tone: .rose),
                card("bathroom", "Bathroom", tone: .teal),
                card("break", "Break", tone: .indigo),
                card("medicine", "Medicine", tone: .rose),
                card("blanket", "Blanket", tone: .violet),
                card("space", "Space", tone: .cyan)
            ]),
            card("person", "I want", tone: .emerald, prompt: "Who do you want?", options: [
                card("mom", "Mom", tone: .rose),
                card("dad", "Dad", tone: .sky),
                card("friend", "Friend", tone: .yellow),
                card("teacher", "Teacher", tone: .cyan),
                card("doctor", "Doctor", tone: .teal),
                card("caregiver", "Caregiver", tone: .emerald)
            ]),
            card("answer", "Answer", tone: .teal, prompt: "Choose an answer", options: [
                card("yes", "Yes", tone: .emerald),
                card("no", "No", tone: .rose),
                card("maybe", "Maybe", tone: .violet),
                card("more", "More", tone: .cyan),
                card("finished", "Finished", tone: .teal),
                card("stop", "Stop", tone: .orange)
            ]),
            card("not-okay", "Not okay", tone: .orange, prompt: "What is wrong?", options: [
                card("sick", "Sick", tone: .rose),
                card("scared", "Scared", tone: .orange),
                card("loud", "Too loud", tone: .amber),
                card("tired", "Tired", tone: .indigo),
                card("body", "Body", tone: .emerald),
                card("help", "Need help", tone: .sky)
            ]),
            card("see", "I see", tone: .violet, prompt: "What do you see?", options: [
                card("person", "Person", tone: .emerald),
                card("animal", "Animal", tone: .yellow),
                card("car", "Car", tone: .sky),
                card("food", "Food", tone: .amber),
                card("outside", "Outside", tone: .yellow),
                card("something-scary", "Scary thing", tone: .rose)
            ]),
            card("hear", "I hear", tone: .indigo, prompt: "What do you hear?", options: [
                card("music", "Music", tone: .violet),
                card("loud", "Loud sound", tone: .orange),
                card("voice", "Voice", tone: .cyan),
                card("quiet", "Quiet", tone: .sky)
            ])
        ]
    )

    private static func card(
        _ id: String,
        _ label: String,
        tone: CardTone? = nil,
        prompt: String? = nil,
        minMode: VocabularyMode? = nil,
        options: [AACCard] = []
    ) -> AACCard {
        AACCard(
            id: id,
            label: label,
            emoji: emoji(for: id),
            tone: tone ?? Self.tone(for: id),
            prompt: prompt,
            minMode: minMode,
            options: options
        )
    }
}
