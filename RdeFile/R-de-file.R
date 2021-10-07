# Rでファイル読み込みを頑張る！
# 頑張ってみる

# ⓪ ようはこれを今日は簡単にできるようになりたい！
d1 = read.csv("~/Desktop/RdeFile/data/result1.csv")
d2 = read.csv("~/Desktop/RdeFile/data/result2.csv")
d3 = read.csv("~/Desktop/RdeFile/data/result3.csv")
d4 = read.csv("~/Desktop/RdeFile/data/result4.csv")

d = rbind(d1,d2,d3,d4)

# ①アホでもできる！file.choose() (Windowsの場合choose.files())
file.choose() 


# ② ディレクトリを変えて、ファイルを読み込んでみよう
# session -> set working directory -> choose directory
setwd("hundara/hundara")

# これは便利！黒魔術だと思って使えばいい
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
dirname(rstudioapi::getActiveDocumentContext()$path)

# ③ 1つ1つのファイルの読み込みなんてやってらんねえよって人向け
setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/data"))
list.files()
files = list.files()

# こんな感じでできそう！
read.csv(files[1])


# ④ 一片に読み込む
lapply(files, read.csv)
allData = lapply(files, read.csv)

# リスト形式からデータフレームにする
do.call(rbind, allData)


# ⑤　ファイル名とかの情報残しときたくない？俺は残したい
# 君だけのオリジナルread.csv()を作ろう！
ore_no_read.csv = function(filename){
  d = read.csv(filename)
  d$filename = filename
  return(d)
}

# やったね！
do.call(rbind, lapply(files, ore_no_read.csv) )


# というわけで、いい感じでデータが読み込めましたとさ
# グラフくらいは描いといてやるか
d = do.call(rbind, lapply(files, ore_no_read.csv) )
d

library(ggplot2)
ggplot(d) + 
  geom_line(aes(x=session, y=result, colour=condition, group=filename))

# パチパチ

# なんちゃらごとに処理をするみたいなときにも便利
# 例えば条件ごとに平均とるとか？

# ビギナーがやりがちなやり方
d_A = d[d$condition=="A",]
d_B = d[d$condition=="B",]

mean_A = mean(d_A$result)
mean_B= mean(d_B$result)
Mean = c(mean_A,mean_B)

# 別のやり方
split(d, d$condition)
splitted_d = split(d, d$condition)

lapply(splitted_d, function(d) mean(d$result))
mean_d = lapply(splitted_d, function(d) mean(d$result))

unlist(mean_d)

# 一気にやろう
unlist(lapply(split(d, d$condition), function(d) mean(d$result)))

# 警察の人向けのコメント
# 多分tidyverse警察の人がgroup_by()使えとか言ってくるけど
# うるせーばーか
# それじゃあパイプくらいは使ってやるよ

library(tidyverse)
split(d, d$condition) %>% lapply(., function(d) mean(d$result)) %>% unlist
# 見やすい！


# もう一例
# 被験者ごとに平均値出して、
# 平均値のデータフレームを作ってみようか

mean_dataframe = function(d){
  data.frame(M = mean(d$result),
             condition = d$condition[1],
             file = d$filename[1])
}

mean_dataframe(d)

split(d, d$file) %>% lapply(., mean_dataframe) %>% do.call(rbind,.)
d.mean = split(d, d$file) %>% lapply(., mean_dataframe) %>% do.call(rbind,.)

ggplot(d.mean) + 
  geom_point(aes(x=condition, y=M, colour = condition), size=5)

