img_id=$(date +"%S%M%H%d%m%Y")
rm -rf train_data
mkdir train_data
/Users/chasereynders/Desktop/yale/academics/third-year/fall-semester/PLSC349/final/.venv/bin/python3 data_collector.py $img_id
Rscript plot_generator.r $img_id
cat new_train_img_data.json > train_img_data.json
rm new_train_img_data.json
sleep 0.5
/Users/chasereynders/Desktop/yale/academics/third-year/fall-semester/PLSC349/final/.venv/bin/python3 trim_plots.py $img_id
unset img_id
