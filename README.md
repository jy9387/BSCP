## BSCP
### Shape recognition based on the combination of contour information and skeleton information.

Codes for our **PRL2016** paper: **"Shape Recognition by Bag of Skeleton-associated Contour Parts"**. [[paper]](http://arxiv.org/abs/1605.06417)

![bscp_pipeline](http://o7zt4a6os.bkt.clouddn.com/bscp_pipeline.png)
#### Requirements:

1. Dataset: we use **Animal Dataset** [[paper]](http://mc.eistar.net/UpLoadFiles/Papers/%5b11%5d%202009%20ICCV%20Workshop%20Baixiang.pdf) for training and testing. The dataset contains 2000 images, which are divided into 20 classes. We extend the dataset by adding the corresponding skeleton-associated contour maps. Please [[download]](http://o7zt4a6os.bkt.clouddn.com/Animal_BSCP.zip) it and extract it to the "data/" directory for training and testing.

2. Tools: you might download the **pdollar's toolbox** [[download]](https://github.com/pdollar/toolbox) and the **liblinear** [[download]](http://www.csie.ntu.edu.tw/~cjlin/liblinear/), and put them into the "include/" directory.

3. Inference: please see exp_animal.m

More technical details details please refer to our paper.

If you find bugs or have questions, please contact me. Glad to hear from you.

***

Mail: jy9387@outlook.com

Homepage: <http://jy9387.github.io/>