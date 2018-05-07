use std::sync::mpsc;
use std::thread;

struct Counter {
    counter: i32
}

impl Counter {
    pub fn new() -> Counter { Counter { counter: 0 } }
    pub fn incr(&mut self) { self.counter += 1; }
}

enum Message {
    Incr,
    Exit
}

fn main() {
    let (sender, receiver) = mpsc::channel();
    let t = thread::spawn(move || {
        let mut ctr = Counter::new();
        loop {
            let message = receiver.recv().unwrap();
            match message {
                Message::Incr => { ctr.incr(); },
                Message::Exit => { return; }
            };
        }
    });

    sender.send(Message::Incr).unwrap();
    sender.send(Message::Exit).unwrap();

    t.join().unwrap();
}
