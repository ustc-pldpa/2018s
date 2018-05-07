import tensorflow as tf

a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)

c = a + b
d = a * c

with tf.Session() as sess:
    result = sess.run([d], {a: 2, b: 3})
    print(result)
