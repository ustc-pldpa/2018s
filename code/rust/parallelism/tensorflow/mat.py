import tensorflow as tf

x = tf.constant([[1.0, 2.0],
                 [3.0, 4.0]])
y = tf.constant([[1.0, 0.0],
                 [0.0, 1.0]])
z = tf.matmul(x, y)

with tf.Session() as sess:
    print(sess.run(z))
