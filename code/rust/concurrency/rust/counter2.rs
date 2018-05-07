use std::sync::mpsc;
use std::thread;

struct Counter {
    counter: i32
}

impl Counter {
    pub fn new() -> Counter { Counter { counter: 0 } }
    pub fn incr(&mut self) { self.counter += 1; }
    pub fn value(&self) -> i32 { self.counter }
}

enum Message {
    Incr,
    Value,
    Exit
}

fn main() {
    let (input_sender, input_receiver) = mpsc::channel();
    let (output_sender, output_receiver) = mpsc::channel();
    let t = thread::spawn(move || {
        let mut ctr = Counter::new();
        loop {
            let message = input_receiver.recv().unwrap();
            match message {
                Message::Incr => { ctr.incr(); }
                Message::Value => { output_sender.send(ctr.value()).unwrap(); }
                Message::Exit => { return; }
            };
        }
    });

    input_sender.send(Message::Incr).unwrap();
    input_sender.send(Message::Value).unwrap();
    input_sender.send(Message::Exit).unwrap();

    println!("Counter: {}", output_receiver.recv().unwrap());

    t.join().unwrap();
}
