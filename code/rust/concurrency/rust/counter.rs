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
    let (tx, rx) = mpsc::channel();
    let t = thread::spawn(move || {
        let mut ctr = Counter::new();
        loop {
            let message = rx.recv().unwrap();
            match message {
                Message::Incr => { ctr.incr(); },
                Message::Exit => { return; }
            };
        }
    });

    tx.send(Message::Incr).unwrap();
    tx.send(Message::Exit).unwrap();

    t.join().unwrap();
}
