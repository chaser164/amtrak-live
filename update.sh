rm -rf train_data
mkdir train_data
/Users/chasereynders/Desktop/yale/academics/third-year/fall-semester/PLSC349/final/.venv/bin/python3 data_collector.py
Rscript test4.r
cat new_train_img_data.json > train_img_data.json
rm new_train_img_data.json
